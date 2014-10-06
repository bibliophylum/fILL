/*
    fILL - Free/Open-Source Interlibrary Loan management system
    Copyright (C) 2012  Government of Manitoba

    renewal-answer.js is a part of fILL.

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
    myTable.setAttribute("id","renewal-answer-table");
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
    cell = document.createElement("TH"); cell.innerHTML = "Last update"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Due date"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Response"; row.appendChild(cell);
    
    var tFoot = myTable.createTFoot();
    row = tFoot.insertRow(-1);
    cell = row.insertCell(-1); cell.colSpan = "11"; cell.innerHTML = "As requests are handled, they are removed from this list.  You can see the status of all of your active ILLs in the \"Current ILLs\" screen.";
    
    // explicit creation of TBODY element to make IE happy
    var tBody = document.createElement("TBODY");
    myTable.appendChild(tBody);
    
//    alert('building rows');
    for (var i=0;i<data.renewRequests.length;i++) 
    {
//	alert (data.renewRequests[i].id+" "+data.renewRequests[i].msg_from+" "+data.renewRequests[i].call_number+" "+data.renewRequests[i].author+" "+data.renewRequests[i].title+" "+data.renewRequests[i].ts); //further debug
        row = tBody.insertRow(-1); row.id = 'req'+data.renewRequests[i].id;
        cell = row.insertCell(-1); cell.innerHTML = data.renewRequests[i].gid;
        cell = row.insertCell(-1); cell.innerHTML = data.renewRequests[i].cid;
        cell = row.insertCell(-1); cell.innerHTML = data.renewRequests[i].id;
        cell = row.insertCell(-1); cell.innerHTML = data.renewRequests[i].from; cell.setAttribute('title', data.renewRequests[i].library);
        cell = row.insertCell(-1); cell.innerHTML = data.renewRequests[i].msg_from;
        cell = row.insertCell(-1); cell.innerHTML = data.renewRequests[i].call_number;
        cell = row.insertCell(-1); cell.innerHTML = data.renewRequests[i].author;
        cell = row.insertCell(-1); cell.innerHTML = data.renewRequests[i].title;
        cell = row.insertCell(-1); cell.innerHTML = data.renewRequests[i].ts;
	// Need to set a default due date:
	var now = new Date();
	var d = new Date(now.getTime() + (27 * 24 * 60 * 60 * 1000)); 
// Doesn't work on older version of Internet Explorer...
//	var iso = d.toISOString();
	var month = d.getMonth()+1;
	var day = d.getDate();
	var iso = d.getFullYear() + '-' +
	    ((''+month).length<2 ? '0' : '') + month + '-' +
	    ((''+day).length<2 ? '0' : '') + day;
        cell = row.insertCell(-1); cell.innerHTML = iso.substring(0,10);
        cell = row.insertCell(-1); 

	var divResponses = document.createElement("div");
	divResponses.id = 'divResponses'+data.renewRequests[i].id;

	var requestId = data.renewRequests[i].id;

	var b1 = document.createElement("input");
	b1.type = "button";
	b1.value = "Renew OK";
	b1.onclick = make_renewalAnswer_handler( requestId );
	divResponses.appendChild(b1);
	
	var b2 = document.createElement("input");
	b2.type = "button";
	b2.value = "Can\'t renew";
	b2.onclick = make_cannotRenew_handler( requestId );
	divResponses.appendChild(b2);

	cell.appendChild( divResponses );
    }
    
    document.getElementById('mylistDiv').appendChild(myTable);
    
    toggleLayer("waitDiv");
    toggleLayer("mylistDiv");
}

// Explanation of why we need a function to create the buttons' onclick handlers:
// http://www.webdeveloper.com/forum/archive/index.php/t-100584.html
// Short answer: scoping and closures

function make_renewalAnswer_handler( requestId ) {
    return function() { renewalAnswer( requestId ) };
}

function renewalAnswer( requestId ) {
    var myRow=$("#req"+requestId);
    if (myRow.find(':nth-child(10)').text().length == 0) {
	var retVal = confirm("You have not entered a due date.  Continue without due date?");
	if (retVal == false) {
	    // bail out to let the user enter a due date
 	    return false;
	}
    }

    var parms = {
	"reqid": requestId,
	"msg_to": myRow.find(':nth-child(5)').text(),
	"lid": $("#lid").text(),
	"status": "Renew-Answer|Ok",
	"message": "due "+myRow.find(':nth-child(10)').text()
    };
    $.getJSON('/cgi-bin/change-request-status.cgi', parms,
	      function(data){
		  //alert('change request status: '+data+'\n'+parms.status);
	      })
        .success(function() {
	    //alert('success');
	})
	.error(function() {
	    alert('error');
	})
	.complete(function() {
	    // slideUp doesn't work for <tr>
	    $("#req"+requestId).fadeOut(400, function() { $(this).remove(); }); // toast the row
	});
}

function make_cannotRenew_handler( requestId ) {
    return function() { cannotRenew( requestId ) };
}

function cannotRenew( requestId ) {
    var myRow=$("#req"+requestId);

    var crDiv = document.createElement("div");
    crDiv.id = "cannotRenewMessage";
    var crForm = document.createElement("form");
    crDiv.appendChild(crForm);
    myRow[0].cells[10].appendChild(crDiv);

    $("#divResponses"+requestId).hide();

    $("<p />").text("You can enter a message if you'd like:").appendTo(crForm);
    $("<input />").attr({'type':'text','id':'crmsg'}).appendTo(crForm);
    var cButton = $("<input type='button' value='Cancel'>").appendTo(crForm);
    cButton.bind('click', function() {
	$("#cannotRenewMessage").remove(); 
	$("#divResponses"+requestId).show(); 
	//return false;
    });

    var sButton = $("<input type='submit' value='Submit'>").appendTo(crForm);
    sButton.bind('click', function() {
	var reason = $('input:[id=crmsg]').val();
	$("#cannotRenewMessage").remove(); 
	$("#divResponses"+requestId).show(); 
	var parms = {
	    "reqid": requestId,
	    "msg_to": myRow.find(':nth-child(5)').text(),
	    "lid": $("#lid").text(),
	    "status": "Renew-Answer|No-renewal",
	    "message": reason
	};

	$.getJSON('/cgi-bin/change-request-status.cgi', parms,
		  function(data){
		      //alert('change request status: '+data+'\n'+parms.status);
		  })
            .success(function() {
		//alert('success');
	    })
	    .error(function() {
		alert('error');
	    })
	    .complete(function() {
		// slideUp doesn't work for <tr>
		$("#req"+requestId).fadeOut(400, function() { $(this).remove(); }); // toast the row
	    });
    });
}

function set_default_due_date(oForm) {
//    var defaultDueDate = oForm.elements["year"].value + '-' + oForm.elements["month"].value + '-' + oForm.elements["day"].value;
    var defaultDueDate = oForm.elements["datepicker"].value;
    var theTable = document.getElementById('gradient-style');

    for( var r = 0; r < theTable.tBodies[0].rows.length; r++ ) {
	theTable.tBodies[0].rows[r].cells[9].innerHTML = defaultDueDate;
    }
    $("#gradient-style > tbody > tr > td:nth-child(10)").stop(true,true).effect("highlight", {}, 2000);
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


