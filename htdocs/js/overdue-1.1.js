// overdue.js
/*
    fILL - Free/Open-Source Interlibrary Loan management system
    Copyright (C) 2012  Government of Manitoba

    overdue.js is a part of fILL.

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
    //alert( 'in build_table' );
    var myTable = document.createElement("table");
    myTable.setAttribute("id","overdue-table");
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
    cell = document.createElement("TH"); cell.innerHTML = "Borrowed from"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Borrowed from (ID)"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Last update"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Due date"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Patron"; row.appendChild(cell);
    
    var tFoot = myTable.createTFoot();
    row = tFoot.insertRow(-1);
    cell = row.insertCell(-1); cell.colSpan = "10"; cell.innerHTML = "These items are now overdue.";
    
    // explicit creation of TBODY element to make IE happy
    var tBody = document.createElement("TBODY");
    myTable.appendChild(tBody);
    
//    alert('building rows');
    for (var i=0;i<data.overdue.length;i++) 
    {
//	alert (data.overdue[i].id+" "+data.overdue[i].msg_from+" "+data.overdue[i].call_number+" "+data.overdue[i].author+" "+data.overdue[i].title+" "+data.overdue[i].ts); //further debug
        row = tBody.insertRow(-1); row.id = 'req'+data.overdue[i].id;
        cell = row.insertCell(-1); cell.innerHTML = data.overdue[i].gid;
        cell = row.insertCell(-1); cell.innerHTML = data.overdue[i].cid;
        cell = row.insertCell(-1); cell.innerHTML = data.overdue[i].id;
        cell = row.insertCell(-1); cell.innerHTML = data.overdue[i].title;
        cell = row.insertCell(-1); cell.innerHTML = data.overdue[i].author;
        cell = row.insertCell(-1); cell.innerHTML = data.overdue[i].from; cell.setAttribute('title', data.overdue[i].library);
        cell = row.insertCell(-1); cell.innerHTML = data.overdue[i].msg_from;
        cell = row.insertCell(-1); cell.innerHTML = data.overdue[i].ts;
        cell = row.insertCell(-1); cell.innerHTML = data.overdue[i].due_date;
        cell = row.insertCell(-1); cell.innerHTML = data.overdue[i].patron_barcode;
//        cell = row.insertCell(-1); 
//
//	var divResponses = document.createElement("div");
//	divResponses.id = 'divResponses'+data.overdue[i].id;
//
//	var b1 = document.createElement("input");
//	b1.type = "button";
//	b1.value = "Print overdue notice";
//	var requestId = data.overdue[i].id;
//	b1.onclick = make_overdue_handler( requestId );
//	divResponses.appendChild(b1);
//	
//	cell.appendChild( divResponses );
    }
    
    document.getElementById('mylistDiv').appendChild(myTable);
    
    toggleLayer("waitDiv");
    toggleLayer("mylistDiv");
}

// Explanation of why we need a function to create the buttons' onclick handlers:
// http://www.webdeveloper.com/forum/archive/index.php/t-100584.html
// Short answer: scoping and closures

function make_overdue_handler( requestId ) {
    return function() { overdue( requestId ) };
}

function overdue( requestId ) {
    var myRow=$("#req"+requestId);
    var parms = {
	"reqid": requestId,
	"msg_to": myRow.find(':nth-child(7)').text(),
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


