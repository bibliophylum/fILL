// shipping.js
/*
    fILL - Free/Open-Source Interlibrary Loan management system
    Copyright (C) 2012  David A. Christensen

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
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
    
    cell = document.createElement("TH"); cell.innerHTML = "ID"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "From"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "From (ID)"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Author"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Title"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Mailing address"; row.appendChild(cell);
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
    for (var i=0;i<data.shipping.length;i++) 
    {
//	alert (data.shipping[i].id+" "+data.shipping[i].msg_from+" "+data.shipping[i].call_number+" "+data.shipping[i].author+" "+data.shipping[i].title+" "+data.shipping[i].ts); //further debug
        row = tBody.insertRow(-1); row.id = 'req'+data.shipping[i].id;
        cell = row.insertCell(-1); cell.innerHTML = data.shipping[i].id;
        cell = row.insertCell(-1); cell.innerHTML = data.shipping[i].from; cell.setAttribute('title', data.shipping[i].library);
        cell = row.insertCell(-1); cell.innerHTML = data.shipping[i].msg_to;
        cell = row.insertCell(-1); cell.innerHTML = data.shipping[i].author;
        cell = row.insertCell(-1); cell.innerHTML = data.shipping[i].title;
        cell = row.insertCell(-1); cell.innerHTML = data.shipping[i].mailing_address;
        cell = row.insertCell(-1); cell.innerHTML = data.shipping[i].ts;
//        cell = row.insertCell(-1); cell.innerHTML = "";
	// Need to set a default due date:
	var now = new Date();
	var d = new Date(now.getTime() + (21 * 24 * 60 * 60 * 1000)); 
	var iso = d.toISOString();
        cell = row.insertCell(-1); cell.innerHTML = iso.substring(0,10);
        cell = row.insertCell(-1); 

	var requestId = data.shipping[i].id;
	var divResponses = document.createElement("div");
	divResponses.id = 'divResponses'+requestId;

	var b1 = document.createElement("input");
	b1.type = "button";
	b1.value = "Sent";
	b1.onclick = make_shipit_handler( requestId );
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
		status: "Shipped",
		message: "due "+$row.find(':nth-child(8)').text()
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

function set_default_due_date(oForm) {
//    var defaultDueDate = oForm.elements["year"].value + '-' + oForm.elements["month"].value + '-' + oForm.elements["day"].value;
    var defaultDueDate = oForm.elements["datepicker"].value;
    var theTable = document.getElementById('gradient-style');

    for( var r = 0; r < theTable.tBodies[0].rows.length; r++ ) {
	theTable.tBodies[0].rows[r].cells[7].innerHTML = defaultDueDate;
    }
    $("#gradient-style > tbody > tr > td:nth-child(8)").stop(true,true).effect("highlight", {}, 2000);
    return false;
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


