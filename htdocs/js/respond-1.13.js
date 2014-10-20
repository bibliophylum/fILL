// respond.js
/*
    fILL - Free/Open-Source Interlibrary Loan management system
    Copyright (C) 2012  Government of Manitoba

    respond.js is a part of fILL.

    fILL is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    fILL is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
function build_table( data ) {
//    alert( 'in build_table' );

    var myTable = document.createElement("table");
    myTable.setAttribute("id","respond-table");
    var tHead = myTable.createTHead();
    var row = tHead.insertRow(-1);
    var cell;
    // Can't just use:
    // cell = row.insertCell(-1); cell.innerHTML = "ID";
    // ...because insertCell inserts TD elements, and our CSS uses TH for header cells.
    
    cell = document.createElement("TH"); cell.innerHTML = "gid"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "cid"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "ID"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "From"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "From (ID)"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Call #"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Author"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Title"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Note"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Last update"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Format"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Hold requested?"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Response"; row.appendChild(cell);
    
    var tFoot = myTable.createTFoot();
    row = tFoot.insertRow(-1);
    cell = row.insertCell(-1); cell.colSpan = "13"; cell.innerHTML = "As requests are handled, they are removed from this list.  You can see the status of all of your active ILLs in the \"Current ILLs\" screen.";
    
    // explicit creation of TBODY element to make IE happy
    var tBody = document.createElement("TBODY");
    myTable.appendChild(tBody);
    // this needs to happen before the .getJSON call (which might take a moment)
    // to ensure that the datatable-ness in respond.tmpl gets applied
    document.getElementById('mylistDiv').appendChild(myTable);

    build_rows( tBody, data );
    toggleLayer("waitDiv");
    toggleLayer("mylistDiv");
}

//function build_rows( tBody, data, canForward, retargets ) {
function build_rows( tBody, data ) {
    for (var i=0;i<data.unhandledRequests.length;i++) 
    {
	row = tBody.insertRow(-1); row.id = 'req'+data.unhandledRequests[i].id;
	cell = row.insertCell(-1); cell.innerHTML = data.unhandledRequests[i].gid;
	cell = row.insertCell(-1); cell.innerHTML = data.unhandledRequests[i].cid;
	cell = row.insertCell(-1); cell.innerHTML = data.unhandledRequests[i].id;
	cell = row.insertCell(-1); cell.innerHTML = data.unhandledRequests[i].from; cell.setAttribute('title', data.unhandledRequests[i].library);
	cell = row.insertCell(-1); cell.innerHTML = data.unhandledRequests[i].msg_from;
	cell = row.insertCell(-1); cell.innerHTML = data.unhandledRequests[i].call_number;
	cell = row.insertCell(-1); cell.innerHTML = data.unhandledRequests[i].author;
	cell = row.insertCell(-1); cell.innerHTML = data.unhandledRequests[i].title;
	cell = row.insertCell(-1); cell.innerHTML = data.unhandledRequests[i].note;
	cell = row.insertCell(-1); cell.innerHTML = data.unhandledRequests[i].ts;
	cell = row.insertCell(-1); cell.innerHTML = data.unhandledRequests[i].medium;
	cell = row.insertCell(-1); cell.innerHTML = data.unhandledRequests[i].place_on_hold;
	cell = row.insertCell(-1); 
	
	var divResponses = document.createElement("div");
	divResponses.id = 'divResponses'+data.unhandledRequests[i].id;
	
	var b1 = document.createElement("input");
	b1.type = "button";
	b1.value = "Will-supply";
	b1.className = "action-button";
	var requestId = data.unhandledRequests[i].id;
	b1.onclick = make_shipit_handler( requestId );
	divResponses.appendChild(b1);
	
	if (data.canForwardToChildren) {
	    var b2 = document.createElement("input");
	    b2.type = "button";
	    b2.value = "Forward to branch";
	    b2.className = "action-button";
	    b2.onclick = make_forward_handler( requestId, data.retargets );
	    divResponses.appendChild(b2);
	}
	
	var b3 = document.createElement("input");
	b3.type = "button";
	b3.value = "Unfilled";
	b3.className = "action-button";
	b3.onclick = make_unfilled_handler( requestId );
	divResponses.appendChild(b3);
	
	if (data.unhandledRequests[i].place_on_hold != "no") {
	    var b4 = document.createElement("input");
	    b4.type = "button";
	    b4.value = "Hold placed";
	    b4.className = "action-button";
	    b4.onclick = make_hold_placed_handler( requestId );
	    divResponses.appendChild(b4);
	}

	cell.appendChild( divResponses );
    }
}

// Explanation of why we need a function to create the buttons' onclick handlers:
// http://www.webdeveloper.com/forum/archive/index.php/t-100584.html
// Short answer: scoping and closures

function make_hold_placed_handler( requestId ) {
    return function() { holdplaced( requestId ) };
}

function holdplaced( requestId ) {
    var myRow=$("#req"+requestId);
    var hpDiv = document.createElement("div");
    hpDiv.id = "expectedDate";
    var hpForm = document.createElement("form");

    var hp = document.createElement("div");
    hp.setAttribute('id','setDate');
    hpForm.appendChild(hp);
    hpDiv.appendChild(hpForm);
    $("<tr id='tmprow'><td></td><td id='tmpcol' colspan='13'></td></tr>").insertAfter($("#req"+requestId));
    $("#tmpcol").append(hpDiv);

    $("#divResponses"+requestId).hide();
    $( "<p>What date do you expect the hold to be filled?</p>" ).insertBefore("#setDate");

    $("<p><input id='dateAvailable' type='text' size='12' maxlength='12' /></p>").insertAfter("#setDate");

    var dateAvailable = moment();
    dateAvailable = dateAvailable.add('months',1);
    
    $("#dateAvailable").datepicker({ dateFormat: 'yy-mm-dd', defaultDate: '+1m' });
    $("#dateAvailable").datepicker('setDate', dateAvailable.native() );
    

    var cButton = $("<input type='button' value='Cancel'>").appendTo(hpForm);
    cButton.bind('click', function() {
	$("#expectedDate").remove(); 
	$("#tmprow").remove();
	$("#divResponses"+requestId).show(); 
	//return false;
    });

    var sButton = $("<input type='submit' value='Submit'>").appendTo(hpForm);
    sButton.bind('click', function() {
        var expected = moment( $("#dateAvailable").datepicker("getDate") ).format("YYYY-MM-DD");
//	alert(expected);
	$("#expectedDate").remove(); 
	$("#tmprow").remove();
	$("#divResponses"+requestId).show(); 
	
	var myRow=$("#req"+requestId);
	var parms = {
	    "reqid": requestId,
	    "msg_to": myRow.find(':nth-child(5)').text(),  // sending TO whoever original was FROM
	    "lid": $("#lid").text(),
	    "status": "ILL-Answer|Hold-Placed|estimated-date-available",
	    "message": expected
	};
	$.getJSON('/cgi-bin/change-request-status.cgi', parms,
		  function(data){
		      // slideUp doesn't work for <tr>
		      $("#req"+requestId).fadeOut(400, function() { $("req"+requestId).remove(); }); // toast the row
		  })
	    .success(function() {
		update_menu_counters( $("#lid").text() );
	    });
	
    });
}

function make_shipit_handler( requestId ) {
    return function() { shipit( requestId ) };
}

function shipit( requestId ) {
    var myRow=$("#req"+requestId);
    var parms = {
	"reqid": requestId,
	"msg_to": myRow.find(':nth-child(5)').text(),
	"lid": $("#lid").text(),
	"status": "ILL-Answer|Will-Supply|being-processed-for-supply",
	"message": ""
    };
    $.getJSON('/cgi-bin/change-request-status.cgi', parms,
	      function(data){
//		  alert('change request status: '+data+'\n'+parms[0].status);
	      })
	.success(function() {
	    update_menu_counters( $("#lid").text() );
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
    $("<tr id='tmprow'><td></td><td id='tmpcol' colspan='9'></td></tr>").insertAfter($("#req"+requestId));
    $("#tmpcol").append(ruDiv);

    $("#divResponses"+requestId).hide();
    $( "<p>Select the reason that you cannot fill:</p>" ).insertBefore("#unfilledradioset");

    $("<p>Optional message to borrower: <input type='text' name='message' size='40' maxlength='100' /></p>").insertAfter("#unfilledradioset");

    var cButton = $("<input type='button' value='Cancel'>").appendTo(ruForm);
    cButton.bind('click', function() {
	$("#reasonUnfilled").remove(); 
	$("#tmprow").remove();
	$("#divResponses"+requestId).show(); 
	//return false;
    });

    var sButton = $("<input type='submit' value='Submit'>").appendTo(ruForm);
    sButton.bind('click', function() {
	var reason = $('input:radio[name=radioset]:checked').val();
	var optionalMessage = $('input:text[name=message]').val();
	$("#reasonUnfilled").remove(); 
	$("#tmprow").remove();
	$("#divResponses"+requestId).show(); 
	
	var myRow=$("#req"+requestId);
	var parms = {
	    "reqid": requestId,
	    "msg_to": myRow.find(':nth-child(5)').text(),  // sending TO whoever original was FROM
	    "lid": $("#lid").text(),
	    "status": "ILL-Answer|Unfilled|"+reason,
	    "message": optionalMessage
	};
	$.getJSON('/cgi-bin/change-request-status.cgi', parms,
		  function(data){
		      // slideUp doesn't work for <tr>
		      $("#req"+requestId).fadeOut(400, function() { $("req"+requestId).remove(); }); // toast the row
		  })
	    .success(function() {
		update_menu_counters( $("#lid").text() );
	    });
	
    });

    // do this in jQuery... FF and IE handle DOM-created radiobuttons differently.
    $("#unfilledradioset").buttonset();
    $("#unfilledradioset").append("<input type='radio' name='radioset' value='in-use-on-loan' id='in-use-on-loan' checked='checked'/><label for='in-use-on-loan'>in-use-on-loan</label>");
    $("#unfilledradioset").append("<input type='radio' name='radioset' value='in-process' id='in-process'/><label for='in-process'>in-process</label>");
    $("#unfilledradioset").append("<input type='radio' name='radioset' value='lost' id='lost'/><label for='lost'>lost</label>");
    $("#unfilledradioset").append("<input type='radio' name='radioset' value='non-circulating' id='non-circulating'/><label for='non-circulating'>non-circulating</label>");
    $("#unfilledradioset").append("<input type='radio' name='radioset' value='not-owned' id='not-owned'/><label for='not-owned'>not-owned</label>");
    $("#unfilledradioset").append("<input type='radio' name='radioset' value='on-order' id='on-order'/><label for='on-order'>on-order</label>");
    $("#unfilledradioset").append("<input type='radio' name='radioset' value='not-on-shelf' id='not-on-shelf'/><label for='not-on-shelf'>not-on-shelf</label>");
    $("#unfilledradioset").append("<input type='radio' name='radioset' value='on-reserve' id='on-reserve'/><label for='on-reserve'>on-reserve</label>");
    $("#unfilledradioset").append("<input type='radio' name='radioset' value='poor-condition' id='poor-condition'/><label for='poor-condition'>poor-condition</label>");
    $("#unfilledradioset").append("<input type='radio' name='radioset' value='charges' id='charges'/><label for='charges'>charges</label>");
    $("#unfilledradioset").append("<input type='radio' name='radioset' value='on-hold' id='on-hold'/><label for='on-hold'>on-hold</label>");
    $("#unfilledradioset").append("<input type='radio' name='radioset' value='policy-problem' id='policy-problem'/><label for='policy-problem'>policy-problem</label>");
    $("#unfilledradioset").append("<input type='radio' name='radioset' value='other' id='other'/><label for='other'>other</label>");
//    $("#unfilledradioset").append("<input type='radio' name='radioset' value='responder-specific' id='responder-specific'/><label for='responder-specific'>responder-specific</label>");
    $("#unfilledradioset").buttonset('refresh');
}

function make_forward_handler( requestId, retargets ) {
    return function() { forward( requestId, retargets ) };
}

function forward( requestId, retargets ) {
    var row = $("#req"+requestId);
    var ruDiv = document.createElement("div");
    ruDiv.id = "branchForward";
    var ruForm = document.createElement("form");

    var ru = document.createElement("div");
    ru.setAttribute('id','forwardradioset');
    ruForm.appendChild(ru);
    ruDiv.appendChild(ruForm);
    $("<tr id='tmprow'><td></td><td id='tmpcol' colspan='11'></td></tr>").insertAfter($("#req"+requestId));
    $("#tmpcol").append(ruDiv);

    $("#divResponses"+requestId).hide();
    $( "<p>Select the branch to foward this request to:</p>" ).insertBefore("#forwardradioset");


    var cButton = $("<input type='button' value='Cancel'>").appendTo(ruForm);
    cButton.bind('click', function() {
	$("#branchForward").remove(); 
	$("#tmprow").remove();
	$("#divResponses"+requestId).show(); 
	//return false;
    });

    var sButton = $("<input type='submit' value='Submit'>").appendTo(ruForm);
    sButton.bind('click', function() {
	var forwardTo = $('input:radio[name=radioset]:checked').val();
	$("#branchForward").remove(); 
	$("#tmprow").remove();
	$("#divResponses"+requestId).show(); 
	
	// Note that nth-child uses 1-based indexing, not 0-based
	var parms = $('#gradient-style tbody tr').map(function() {
	    // $(this) is used more than once; cache it for performance.
	    var $row = $(this);
	    if ($row.find(':nth-child(3)').text() == requestId) {
		var targetIndex;
		for (var i=0; i < retargets.length; i++) {
		    if (retargets[i].lid == forwardTo)
			targetIndex = i;
		}
		return {
		    reqid: requestId,
		    msg_to: $row.find(':nth-child(5)').text(),  // sending TO whoever original was FROM
		    lid: $("#lid").text(),
		    status: "ILL-Answer|Locations-provided|responder-specific",
		    message: "forwarded to our branch "+retargets[targetIndex].name
		}
	    } else {
		return null;
	    };
	}).get();

	$.getJSON('/cgi-bin/change-request-status.cgi', parms[0],
		  function(data){
		      // create request from borrower to new lender
		      $.getJSON('/cgi-bin/change-request-status.cgi',
				{ reqid: requestId,
				  msg_to: forwardTo,
				  lid: parms[0].msg_to,  // sending FROM whoever original was FROM (which is whoever we sent the response to
				  status: "ILL-Request",
				  message: ""
				},
				function() {
				    // slideUp doesn't work for <tr>
				    $("#req"+requestId).fadeOut(400, function() { $("req"+requestId).remove(); }); // toast the row
				})
			  .error(function() {
			      alert('Could not create new ILL-Request.');
			  });
		  })
	    .success(function() {
		$.getJSON('/cgi-bin/update-source-on-forward.cgi',
			  { reqid: requestId,
			    hq: $("#lid").text(),
			    branch: forwardTo
			  },
			  function() {
			      //alert("sources updated - branch is now source");
			  });
		update_menu_counters( $("#lid").text() );
	    });
	
    });

    // do this in jQuery... FF and IE handle DOM-created radiobuttons differently.
    $("#forwardradioset").buttonset();
//    retargets.forEach(function(target){
//	var s="<input type='radio' name='radioset' value='"+target.lid+"' id='"+target.name+"'/><label for='"+target.name+"'>"+target.city+"</label>";
//	$("#forwardradioset").append(s);
//    });

    for (var i = 0; i < retargets.length; i++) {
	var s="<input type='radio' name='radioset' value='"+retargets[i].lid+"' id='"+retargets[i].name+"'/><label for='"+retargets[i].name+"'>"+retargets[i].city+"</label>";
	$("#forwardradioset").append(s);
    }

    $("#forwardradioset").buttonset('refresh');
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


