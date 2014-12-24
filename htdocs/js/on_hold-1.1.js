// on_hold.js
/*
    fILL - Free/Open-Source Interlibrary Loan management system
    Copyright (C) 2012  Government of Manitoba

    on_hold.js is a part of fILL.

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
    myTable.setAttribute("id","on-hold-table");
    myTable.className = myTable.className + " row-border";
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
    cell = document.createElement("TH"); cell.innerHTML = "Author"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Title"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Hold placed"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Date expected"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Hold fulfillment"; row.appendChild(cell);
    
    var tFoot = myTable.createTFoot();
    row = tFoot.insertRow(-1);
    cell = row.insertCell(-1); cell.colSpan = "10"; cell.innerHTML = "As requests are handled, they are removed from this list.  You can see the status of all of your active ILLs in the \"Current ILLs\" screen.";
    
    // explicit creation of TBODY element to make IE happy
    var tBody = document.createElement("TBODY");
    myTable.appendChild(tBody);
    
    for (var i=0;i<data.on_hold.length;i++) 
    {
        row = tBody.insertRow(-1); row.id = 'req'+data.on_hold[i].id;
        cell = row.insertCell(-1); cell.innerHTML = data.on_hold[i].gid;
        cell = row.insertCell(-1); cell.innerHTML = data.on_hold[i].cid;
        cell = row.insertCell(-1); cell.innerHTML = data.on_hold[i].id;
        cell = row.insertCell(-1); cell.innerHTML = data.on_hold[i].from; cell.setAttribute('title', data.on_hold[i].library);
        cell = row.insertCell(-1); cell.innerHTML = data.on_hold[i].msg_to;
        cell = row.insertCell(-1); cell.innerHTML = data.on_hold[i].author;
        cell = row.insertCell(-1); cell.innerHTML = data.on_hold[i].title;
        cell = row.insertCell(-1); cell.innerHTML = data.on_hold[i].ts;
        cell = row.insertCell(-1); cell.innerHTML = data.on_hold[i].date_expected;
        cell = row.insertCell(-1); 

	var requestId = data.on_hold[i].id;
	var divResponses = document.createElement("div");
	divResponses.id = 'divResponses'+requestId;

	var b1 = document.createElement("input");
	b1.type = "button";
	if (data.on_hold[i].cancel == 1) {
	    b1.value = "Cancelled by borrower";
	    b1.className = "action-button-highlighted";
	    b1.onclick = make_cancelled_handler( requestId );
	} else {
	    b1.value = "Ready to ship";
	    b1.className = "action-button";
	    b1.onclick = make_shipper_handler( requestId );
	}
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

function make_shipper_handler( requestId ) {
    return function() { shipper( requestId ) };
}

function shipper( requestId ) {
    var myRow=$("#req"+requestId);
    var nTr = myRow[0]; // convert jQuery object to DOM
    var oTable = $('#on-hold-table').dataTable();
    var aPos = oTable.fnGetPosition( nTr );
    var msg_to = oTable.fnGetData( aPos )[4]; // 5th column (0-based!), hidden or not

    var parms = {
	"reqid": requestId,
	"msg_to": msg_to,
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

function make_cancelled_handler( requestId ) {
    return function() { cancelled( requestId ) };
}

function cancelled( requestId ) {
    var myRow=$("#req"+requestId);
    var nTr = myRow[0]; // convert jQuery object to DOM
    var oTable = $('#on-hold-table').dataTable();
    var aPos = oTable.fnGetPosition( nTr );
    var msg_to = oTable.fnGetData( aPos )[4]; // 5th column (0-based!), hidden or not

    var parms = {
	"reqid": requestId,
	"msg_to": msg_to,
	"lid": $("#lid").text(),
	"status": "Cancel-Reply",
	"message": "Ok"
    };
    $.getJSON('/cgi-bin/change-request-status.cgi', parms,
	      function(data){
//		  alert('change request status: '+data+'\n'+parms[0].status);
	      })
	.success(function() {
	    $.getJSON('/cgi-bin/move-to-history.cgi', { 'reqid' : requestId },
		      function(data){
			  //alert('Moved to history? '+data.success+'\n  Closed? '+data.closed+'\n  History? '+data.history+'\n  Active? '+data.active+'\n  Sources? '+data.sources+'\n  Request? '+data.request);
		      });
	})
	.error(function() {
	    alert('error');
	})
	.complete(function() {
	    update_menu_counters( $("#lid").text() );
	    // slideUp doesn't work for <tr>
	    $("#req"+requestId).fadeOut(400, function() { $(this).remove(); }); // toast the row
	});
}
