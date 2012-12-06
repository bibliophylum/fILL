// renewals.js
/*
    fILL - Free/Open-Source Interlibrary Loan management system
    Copyright (C) 2012  Government of Manitoba

    renewals.js is a part of fILL.

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
    myTable.setAttribute("id","gradient-style");
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
    cell = document.createElement("TH"); cell.innerHTML = "Patron"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Timestamp"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Lender"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Lender (ID)"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Status"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Message"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Renewal"; row.appendChild(cell);
    
    var tFoot = myTable.createTFoot();
    row = tFoot.insertRow(-1);
    cell = row.insertCell(-1); cell.colSpan = "12"; cell.innerHTML = "As you ask for renewals, items are removed from this list.  You can see the status of all of your active ILLs in the \"Current ILLs\" screen.";
    
    // explicit creation of TBODY element to make IE happy
    var tBody = document.createElement("TBODY");
    myTable.appendChild(tBody);
    
//    alert('building rows');
    for (var i=0;i<data.renewals.length;i++) 
    {
//	alert (data.renewals[i].id+" "+data.renewals[i].msg_from+" "+data.renewals[i].call_number+" "+data.renewals[i].author+" "+data.renewals[i].title+" "+data.renewals[i].ts); //further debug
        row = tBody.insertRow(-1); row.id = 'req'+data.renewals[i].id;
        cell = row.insertCell(-1); cell.innerHTML = data.renewals[i].gid;
        cell = row.insertCell(-1); cell.innerHTML = data.renewals[i].cid;
        cell = row.insertCell(-1); cell.innerHTML = data.renewals[i].id;
        cell = row.insertCell(-1); cell.innerHTML = data.renewals[i].title;
        cell = row.insertCell(-1); cell.innerHTML = data.renewals[i].author;
        cell = row.insertCell(-1); cell.innerHTML = data.renewals[i].patron_barcode;
        cell = row.insertCell(-1); cell.innerHTML = data.renewals[i].ts;
	if (data.renewals[i].status.search(/Renew-Answer/) != -1) {
            cell = row.insertCell(-1); cell.innerHTML = data.renewals[i].from; cell.setAttribute('title', data.renewals[i].from_library);
            cell = row.insertCell(-1); cell.innerHTML = data.renewals[i].msg_from;
	} else {
            cell = row.insertCell(-1); cell.innerHTML = data.renewals[i].to; cell.setAttribute('title', data.renewals[i].to_library);
            cell = row.insertCell(-1); cell.innerHTML = data.renewals[i].msg_to;
	}
        cell = row.insertCell(-1); cell.innerHTML = data.renewals[i].status;
        cell = row.insertCell(-1); cell.innerHTML = data.renewals[i].message;
        cell = row.insertCell(-1); 

	var divResponses = document.createElement("div");
	divResponses.id = 'divResponses'+data.renewals[i].id;

	if (data.renewals[i].status == 'Received') {
	    var b1 = document.createElement("input");
	    b1.type = "button";
	    b1.value = "Ask for renewal";
	    var requestId = data.renewals[i].id;
	    b1.onclick = make_renewals_handler( requestId );
	    divResponses.appendChild(b1);
	}
	
	cell.appendChild( divResponses );
    }
    
    document.getElementById('mylistDiv').appendChild(myTable);
    
    toggleLayer("waitDiv");
    toggleLayer("mylistDiv");
}

// Explanation of why we need a function to create the buttons' onclick handlers:
// http://www.webdeveloper.com/forum/archive/index.php/t-100584.html
// Short answer: scoping and closures

function make_renewals_handler( requestId ) {
    return function() { request_renewal( requestId ) };
}

function request_renewal( requestId ) {
    var myRow=$("#req"+requestId);
    var parms = {
	"reqid": requestId,
	"msg_to": myRow.find(':nth-child(9)').text(),
	"lid": $("#lid").text(),
	"status": "Renew",
	"message": ""
    };
    $.getJSON('/cgi-bin/change-request-status.cgi', parms,
	      function(data){
//		  alert('change request status: '+data+'\n'+parms[0].status);
	      })
	.success(function() {
	    // alert('success');
	    // print slip (single) / add to slip page (multi) / do nothing (none)
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


