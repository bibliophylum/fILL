// respond.js
function build_table( data ) {
//    alert( 'in build_table' );
    var myTable = document.createElement("table");
    myTable.setAttribute("id","gradient-style");
    var tHead = myTable.createTHead();
    var row = tHead.insertRow(-1);
    var cell;
    // Can't just use:
    // cell = row.insertCell(-1); cell.innerHTML = "ID";
    // ...because insertCell inserts TD elements, and our CSS uses TH for header cells.
    
    cell = document.createElement("TH"); cell.innerHTML = "ID"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "From"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "From (ID)"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Call #"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Author"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Title"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Timestamp"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Due date"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Response"; row.appendChild(cell);
    
    var tFoot = myTable.createTFoot();
    row = tFoot.insertRow(-1);
    cell = row.insertCell(-1); cell.colSpan = "9"; cell.innerHTML = "As requests are handled, they are removed from this list.  You can see the status of all of your active ILLs in the \"Current ILLs\" screen.";
    
    // explicit creation of TBODY element to make IE happy
    var tBody = document.createElement("TBODY");
    myTable.appendChild(tBody);
    
//    alert('building rows');
    for (var i=0;i<data.unhandledRequests.length;i++) 
    {
//	alert (data.unhandledRequests[i].id+" "+data.unhandledRequests[i].msg_from+" "+data.unhandledRequests[i].call_number+" "+data.unhandledRequests[i].author+" "+data.unhandledRequests[i].title+" "+data.unhandledRequests[i].ts); //further debug
        row = tBody.insertRow(-1); row.id = 'req'+data.unhandledRequests[i].id;
        cell = row.insertCell(-1); cell.innerHTML = data.unhandledRequests[i].id;
        cell = row.insertCell(-1); cell.innerHTML = data.unhandledRequests[i].from;
        cell = row.insertCell(-1); cell.innerHTML = data.unhandledRequests[i].msg_from;
        cell = row.insertCell(-1); cell.innerHTML = data.unhandledRequests[i].call_number;
        cell = row.insertCell(-1); cell.innerHTML = data.unhandledRequests[i].author;
        cell = row.insertCell(-1); cell.innerHTML = data.unhandledRequests[i].title;
        cell = row.insertCell(-1); cell.innerHTML = data.unhandledRequests[i].ts;
        cell = row.insertCell(-1); cell.innerHTML = "";
        cell = row.insertCell(-1); 

	var divResponses = document.createElement("div");
	divResponses.id = 'divResponses'+data.unhandledRequests[i].id;

	var b1 = document.createElement("input");
	b1.type = "button";
	b1.value = "Sent";
	var requestId = data.unhandledRequests[i].id;
	b1.onclick = make_shipit_handler( requestId );
	divResponses.appendChild(b1);
	
//	var b2 = document.createElement("input");
//	b2.type = "button";
//	b2.value = "Change due date";
//	b2.onclick = function () { alert('click!'); };
//	divResponses.appendChild(b2);
	
	var b3 = document.createElement("input");
	b3.type = "button";
	b3.value = "Unfilled";
	b3.onclick = make_unfilled_handler( requestId );
	divResponses.appendChild(b3);

	cell.appendChild( divResponses );
    }
    
    document.getElementById('mylistDiv').appendChild(myTable);
    
    toggleLayer("waitDiv");
    toggleLayer("mylistDiv");
}

// Explanation of why we need a function to create the buttons' onclick handlers:
// http://www.webdeveloper.com/forum/archive/index.php/t-100584.html
// Short answer: scoping and closures

function make_shipit_handler( requestId ) {
    return function() { shipit( requestId ) };
}

function shipit( requestId ) {
    // NOTE: this code will find table rows based on cell contents...
    // ...as we now have <tr id='xxx'>, there's an easier way....

    // Returns [{reqid: 12, msg_to: '101'}, 
    //          {reqid: 15, msg_to: '98'},
    // Note that nth-child uses 1-based indexing, not 0-based
    var parms = $('#gradient-style tbody tr').map(function() {
	// $(this) is used more than once; cache it for performance.
	var $row = $(this);
	
	// For each row that's "mapped", return an object that
	//  describes the first and second <td> in the row.
	if ($row.find(':nth-child(1)').text() == requestId) {
	    return {
		reqid: $row.find(':nth-child(1)').text(),
		msg_to: $row.find(':nth-child(3)').text(),  // sending TO whoever original was FROM
		lid: $("#lid").text(),
		status: "ILL-Answer|Will-Supply|being-processed-for-supply",
		message: ""
	    }
	} else {
	    return null;
	};
    }).get();

    $.getJSON('/cgi-bin/change-request-status.cgi', parms[0],
	      function(data){
//		  alert('change request status: '+data+'\n'+parms[0].status);
	      })
	.success(function() {
	    var myRow=$("#req"+requestId);
	    var parms = {
		"reqid": requestId,
		"msg_to": myRow.find(':nth-child(3)').text(),
		"lid": $("#lid").text(),
		"status": "Shipped",
		"message": "due "+myRow.find(':nth-child(8)').text()
	    };
	    $.getJSON('/cgi-bin/change-request-status.cgi', parms,
		      function(data){
//			  alert('change request status: '+data+'\n'+parms.status);
		      });
	})
	.error(function() {
	    alert('error');
	})
	.complete(function() {
	    // slideUp doesn't work for <tr>
	    $("#req"+requestId).fadeOut(400, function() { $(this).remove(); }); // toast the row
	});
}

function make_unfilled_handler( requestId ) {
    return function() { unfilled( requestId ) };
}

function unfilled( requestId ) {
    var row = $("#req"+requestId);
    var ruDiv = document.createElement("div");
    ruDiv.id = "reasonUnfilled";
    var ruForm = document.createElement("form");

    var ru = document.createElement("div");
    ru.setAttribute('id','unfilledradioset');
    ruForm.appendChild(ru);
    ruDiv.appendChild(ruForm);
    row[0].cells[7].appendChild(ruDiv);

    $("#divResponses"+requestId).hide();
    $( "<p>Select the reason that you cannot fill:</p>" ).insertBefore("#unfilledradioset");


    var cButton = $("<input type='button' value='Cancel'>").appendTo(ruForm);
    cButton.bind('click', function() {
	$("#reasonUnfilled").remove(); 
	$("#divResponses"+requestId).show(); 
	//return false;
    });

    var sButton = $("<input type='submit' value='Submit'>").appendTo(ruForm);
    sButton.bind('click', function() {
	var reason = $('input:radio[name=radioset]:checked').val();
	$("#reasonUnfilled").remove(); 
	$("#divResponses"+requestId).show(); 
	
	// Returns [{reqid: 12, msg_to: '101'}, 
	//          {reqid: 15, msg_to: '98'},
	// Note that nth-child uses 1-based indexing, not 0-based
	var parms = $('#gradient-style tbody tr').map(function() {
	    // $(this) is used more than once; cache it for performance.
	    var $row = $(this);
	    
	    // For each row that's "mapped", return an object that
	    //  describes the first and second <td> in the row.
	    if ($row.find(':nth-child(1)').text() == requestId) {
		return {
		    reqid: $row.find(':nth-child(1)').text(),
		    msg_to: $row.find(':nth-child(3)').text(),  // sending TO whoever original was FROM
		    lid: $("#lid").text(),
		    status: "ILL-Answer|Unfilled|"+reason,
		    message: ""
		}
	    } else {
		return null;
	    };
	}).get();

	$.getJSON('/cgi-bin/change-request-status.cgi', parms[0],
		  function(data){
//		      alert('change request status: '+data);
		      // slideUp doesn't work for <tr>
		      $("#req"+requestId).fadeOut(400, function() { $("req"+requestId).remove(); }); // toast the row
		  }
		 );

    });

    // do this in jQuery... FF and IE handle DOM-created radiobuttons differently.
    $("#unfilledradioset").buttonset();
    $("#unfilledradioset").append("<input type='radio' name='radioset' value='in-use-on-loan' id='in-use-on-loan' checked='checked'/><label for='in-use-on-loan'>in-use-on-loan</label>");
    $("#unfilledradioset").append("<input type='radio' name='radioset' value='in-process' id='in-process'/><label for='in-process'>in-process</label>");
    $("#unfilledradioset").append("<input type='radio' name='radioset' value='lost' id='lost'/><label for='lost'>lost</label>");
    $("#unfilledradioset").append("<input type='radio' name='radioset' value='non-circulating' id='non-circulating'/><label for='non-circulating'>non-circulating</label>");
    $("#unfilledradioset").append("<input type='radio' name='radioset' value='not-owned' id='not-owned'/><label for='not-owned'>not-owned</label>");
    $("#unfilledradioset").append("<input type='radio' name='radioset' value='not-on-shelf' id='not-on-shelf'/><label for='not-on-shelf'>not-on-shelf</label>");
    $("#unfilledradioset").append("<input type='radio' name='radioset' value='on-reserve' id='on-reserve'/><label for='on-reserve'>on-reserve</label>");
    $("#unfilledradioset").append("<input type='radio' name='radioset' value='poor-condition' id='poor-condition'/><label for='poor-condition'>poor-condition</label>");
    $("#unfilledradioset").append("<input type='radio' name='radioset' value='charges' id='charges'/><label for='charges'>charges</label>");
    $("#unfilledradioset").append("<input type='radio' name='radioset' value='on-hold' id='on-hold'/><label for='on-hold'>on-hold</label>");
    $("#unfilledradioset").append("<input type='radio' name='radioset' value='policy-problem' id='policy-problem'/><label for='policy-problem'>policy-problem</label>");
    $("#unfilledradioset").append("<input type='radio' name='radioset' value='other' id='other'/><label for='other'>other</label>");
//    $("#unfilledradioset").append("<input type='radio' name='radioset' value='responder-specific' id='responder-specific'/><label for='responder-specific'>responder-specific</label>");
    $("#unfilledradioset").buttonset('refresh');

//    alert(row[0].cells[8]);

    
}



function set_default_due_date(oForm) {
//    var defaultDueDate = oForm.elements["year"].value + '-' + oForm.elements["month"].value + '-' + oForm.elements["day"].value;
    var defaultDueDate = oForm.elements["datepicker"].value;
    var theTable = document.getElementById('gradient-style');

    for( var r = 0; r < theTable.tBodies[0].rows.length; r++ ) {
	theTable.tBodies[0].rows[r].cells[6].innerHTML = defaultDueDate;
    }
    $("#gradient-style > tbody > tr > td:nth-child(8)").stop(true,true).effect("highlight", {}, 2000);
}

function toggleLayer( whichLayer )
{
    var elem, vis;
    if( document.getElementById ) // this is the way the standards work
	elem = document.getElementById( whichLayer );
    else if( document.all ) // this is the way old msie versions work
	elem = document.all[whichLayer];
    else if( document.layers ) // this is the way nn4 works
	elem = document.layers[whichLayer];

    vis = elem.style;
    // if the style.display value is blank we try to figure it out here
    if(vis.display==''&&elem.offsetWidth!=undefined&&elem.offsetHeight!=undefined)
	vis.display = (elem.offsetWidth!=0&&elem.offsetHeight!=0)?'block':'none';
    vis.display = (vis.display==''||vis.display=='block')?'none':'block';
    //    alert('toggled ' + whichLayer);
}

function set_primary_tab(tab_id) {
    document.getElementById(tab_id).className='current_tab';
}

function set_secondary_tab(tab_id) {
    document.getElementById(tab_id).className='current_tab';
}


