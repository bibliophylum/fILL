// checkins.js
/*
    fILL - Free/Open-Source Interlibrary Loan management system
    Copyright (C) 2012  Government of Manitoba

    checkins.js is a part of fILL.

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
    var myTable = document.createElement("table");
    myTable.setAttribute("id","checkins-table");
    var tHead = myTable.createTHead();
    var row = tHead.insertRow(-1);
    var cell;
    // Can't just use:
    // cell = row.insertCell(-1); cell.innerHTML = "ID";
    // ...because insertCell inserts TD elements, and our CSS uses TH for header cells.
    
    cell = document.createElement("TH"); cell.innerHTML = "gid"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "cid"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "ID"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Title"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Author"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Last update"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Back from"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Back from (ID)"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Check-in"; row.appendChild(cell);
    
    var tFoot = myTable.createTFoot();
    row = tFoot.insertRow(-1);
    cell = row.insertCell(-1); cell.colSpan = "9"; cell.innerHTML = "As items are checked in here, they are removed from this list.  They must still be checked in to your ILS.";
    
    // explicit creation of TBODY element to make IE happy
    var tBody = document.createElement("TBODY");
    myTable.appendChild(tBody);
    
    for (var i=0;i<data.checkins.length;i++) 
    {
        row = tBody.insertRow(-1); row.id = 'req'+data.checkins[i].id;
        cell = row.insertCell(-1); cell.innerHTML = data.checkins[i].gid;
        cell = row.insertCell(-1); cell.innerHTML = data.checkins[i].cid;
        cell = row.insertCell(-1); cell.innerHTML = data.checkins[i].id;
        cell = row.insertCell(-1); cell.innerHTML = data.checkins[i].title;
        cell = row.insertCell(-1); cell.innerHTML = data.checkins[i].author;
        cell = row.insertCell(-1); cell.innerHTML = data.checkins[i].ts;
        cell = row.insertCell(-1); cell.innerHTML = data.checkins[i].from; cell.setAttribute('title', data.checkins[i].library);
        cell = row.insertCell(-1); cell.innerHTML = data.checkins[i].msg_from;
        cell = row.insertCell(-1); 

	var divResponses = document.createElement("div");
	divResponses.id = 'divResponses'+data.checkins[i].id;

	var b1 = document.createElement("input");
	b1.type = "button";
	b1.value = "Checked in to ILS";
	b1.className = "action-button";
	var requestId = data.checkins[i].id;
	b1.onclick = make_checkin_handler( requestId );
	divResponses.appendChild(b1);
	
	cell.appendChild( divResponses );
    }
    
    document.getElementById('mylistDiv').appendChild(myTable);
    
    $("#waitDiv").hide();
    $("#mylistDiv").show();
}

// Explanation of why we need a function to create the buttons' onclick handlers:
// http://www.webdeveloper.com/forum/archive/index.php/t-100584.html
// Short answer: scoping and closures

function make_checkin_handler( requestId ) {
    return function() { checkin( requestId ) };
}

function checkin( requestId ) {
    var myRow=$("#req"+requestId);
    var parms = {
	reqid: requestId,
	msg_to: myRow.find(':nth-child(8)').text(),  // sending TO whoever original was FROM
	lid: $("#lid").text(),
	status: "Checked-in",
	message: ""
    }
    $.getJSON('/cgi-bin/change-request-status.cgi', parms,
	      function(data){
//		  alert('change request status: '+data+'\n'+parms[0].status);
	      })
	.success(function() {
	    //alert('success');
	    $.getJSON('/cgi-bin/move-to-history.cgi', { 'reqid' : requestId },
		      function(data){
//			  alert('Moved to history? '+data.success+'\n  Closed? '+data.closed+'\n  History? '+data.history+'\n  Active? '+data.active+'\n  Sources? '+data.sources+'\n  Request? '+data.request);
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

