// unfilled.js
/*
    fILL - Free/Open-Source Interlibrary Loan management system
    Copyright (C) 2012  David A. Christensen

    unfilled.js is a part of fILL.

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
    myTable.setAttribute("id","gradient-style");
    var tHead = myTable.createTHead();
    var row = tHead.insertRow(-1);
    var cell;
    // Can't just use:
    // cell = row.insertCell(-1); cell.innerHTML = "ID";
    // ...because insertCell inserts TD elements, and our CSS uses TH for header cells.
    
    cell = document.createElement("TH"); cell.innerHTML = "ID"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Title"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Author"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Patron"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Timestamp"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "From"; row.appendChild(cell);
//    cell = document.createElement("TH"); cell.innerHTML = "From (ID)"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Status"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Message"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Currently trying #"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Total # sources"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Next lender?"; row.appendChild(cell);
    
    var tFoot = myTable.createTFoot();
    row = tFoot.insertRow(-1);
    cell = row.insertCell(-1); cell.colSpan = "11"; cell.innerHTML = "If there are more lenders to try, you can click 'Try next lender'.  You can see the status of all of your active ILLs in the \"Current ILLs\" screen.";
    
    // explicit creation of TBODY element to make IE happy
    var tBody = document.createElement("TBODY");
    myTable.appendChild(tBody);
    
//    alert('building rows');
    for (var i=0;i<data.unfilled.length;i++) 
    {
        row = tBody.insertRow(-1); row.id = 'req'+data.unfilled[i].id;
        cell = row.insertCell(-1); cell.innerHTML = data.unfilled[i].id;
        cell = row.insertCell(-1); cell.innerHTML = data.unfilled[i].title;
        cell = row.insertCell(-1); cell.innerHTML = data.unfilled[i].author;
        cell = row.insertCell(-1); cell.innerHTML = data.unfilled[i].patron_barcode;
        cell = row.insertCell(-1); cell.innerHTML = data.unfilled[i].ts;
        cell = row.insertCell(-1); cell.innerHTML = data.unfilled[i].from; cell.setAttribute('title', data.unfilled[i].library);
//        cell = row.insertCell(-1); cell.innerHTML = data.unfilled[i].msg_from;
        cell = row.insertCell(-1); cell.innerHTML = data.unfilled[i].status;
        cell = row.insertCell(-1); cell.innerHTML = data.unfilled[i].message;
        cell = row.insertCell(-1); cell.innerHTML = data.unfilled[i].current_source_sequence_number;
        cell = row.insertCell(-1); cell.innerHTML = data.unfilled[i].sources;
        cell = row.insertCell(-1); 

	var divResponses = document.createElement("div");
	divResponses.id = 'divResponses'+data.unfilled[i].id;

	var b1 = document.createElement("input");
	b1.type = "button";
	b1.value = "Try next lender";
	if (+data.unfilled[i].current_source_sequence_number >= +data.unfilled[i].sources) {
	    b1.value = "No further sources";
	    b1.disabled = "disabled";
	}
	var requestId = data.unfilled[i].id;
	b1.onclick = make_trynextlender_handler( requestId );
	divResponses.appendChild(b1);
	
	var b1 = document.createElement("input");
	b1.type = "button";
	b1.value = "Cancel request";
	var requestId = data.unfilled[i].id;
	b1.onclick = make_cancel_handler( requestId );
	divResponses.appendChild(b1);
	
	cell.appendChild( divResponses );
    }
    
    document.getElementById('mylistDiv').appendChild(myTable);
    
    toggleLayer("waitDiv");
    toggleLayer("mylistDiv");
}

// Explanation of why we need a function to create the buttons' onclick handlers:
// http://www.webdeveloper.com/forum/archive/index.php/t-100584.html
// Short answer: scoping and closures

function make_trynextlender_handler( requestId ) {
    return function() { try_next_lender( requestId ) };
}

function try_next_lender( requestId ) {
    var myRow=$("#req"+requestId);
    var parms = {
	reqid: requestId,
	lid: $("#lid").text(),
    }
    $.getJSON('/cgi-bin/try-next-lender.cgi', parms,
	      function(data){
//		  alert('change request status: '+data+'\n'+parms[0].status);
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

function make_cancel_handler( requestId ) {
    return function() { cancel( requestId ) };
}

function cancel( requestId ) {
    var myRow=$("#req"+requestId);
    var parms = {
	reqid: requestId,
	msg_to: $("#lid").text(),  // message to myself
	lid: $("#lid").text(),
	status: "Message",
	message: "Requester closed the request."
    }
    $.getJSON('/cgi-bin/change-request-status.cgi', parms,
	      function(data){
//		  alert('change request status: '+data+'\n'+parms[0].status);
	      })
	.success(function() {
	    //alert('success');
	    $.getJSON('/cgi-bin/move-to-history.cgi', { 'reqid' : requestId },
		      function(data){
			  //alert('Moved to history? '+data.success+'\n  Closed? '+data.closed+'\n  History? '+data.history+'\n  Active? '+data.active+'\n  Sources? '+data.sources+'\n  Request? '+data.request);
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


