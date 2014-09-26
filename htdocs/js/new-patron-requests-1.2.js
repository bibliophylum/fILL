// new-patron-requests.js
/*
    fILL - Free/Open-Source Interlibrary Loan management system
    Copyright (C) 2012  Government of Manitoba

    new-patron-requests.js is a part of fILL.

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
    myTable.setAttribute("id","new-patron-requests-table");
    var tHead = myTable.createTHead();
    var row = tHead.insertRow(-1);
    var cell;
    // Can't just use:
    // cell = row.insertCell(-1); cell.innerHTML = "ID";
    // ...because insertCell inserts TD elements, and our CSS uses TH for header cells.
    
    cell = document.createElement("TH"); cell.innerHTML = "prid"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Timestamp"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Patron"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Card"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Title"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Author"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Medium"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Actions"; row.appendChild(cell);
    
    var tFoot = myTable.createTFoot();
    row = tFoot.insertRow(-1);
    cell = row.insertCell(-1); cell.colSpan = "8"; cell.innerHTML = "These are new requests from your patrons.";
    
    // explicit creation of TBODY element to make IE happy
    var tBody = document.createElement("TBODY");
    myTable.appendChild(tBody);
    
    for (var i=0;i<data.new_patron_requests.length;i++) 
    {
        row = tBody.insertRow(-1); row.id = 'pr'+data.new_patron_requests[i].prid;
        cell = row.insertCell(-1); cell.innerHTML = data.new_patron_requests[i].prid;
        cell = row.insertCell(-1); cell.innerHTML = data.new_patron_requests[i].ts;
        cell = row.insertCell(-1); cell.innerHTML = data.new_patron_requests[i].name;
        cell = row.insertCell(-1); cell.innerHTML = data.new_patron_requests[i].card;
        cell = row.insertCell(-1); cell.innerHTML = data.new_patron_requests[i].title;
        cell = row.insertCell(-1); cell.innerHTML = data.new_patron_requests[i].author;
        cell = row.insertCell(-1); cell.innerHTML = data.new_patron_requests[i].medium;
        cell = row.insertCell(-1); 

	var divResponses = document.createElement("div");
	divResponses.id = 'divResponses'+data.new_patron_requests[i].prid;

	var requestId = data.new_patron_requests[i].prid;

	var is_verified = data.new_patron_requests[i].is_verified;

	if (!is_verified) {
	    var divVerify = document.createElement("div");
	    var oNewP = document.createElement("p");
	    var oText = document.createTextNode("New patron, please verify");
	    oNewP.appendChild(oText);
	    divVerify.appendChild(oNewP);

	    var b3 = document.createElement("input");
	    b3.type = "button";
	    b3.value = "Verified";
	    b3.onclick = make_verify_handler( requestId );
	    divVerify.appendChild(b3);
	    divResponses.appendChild(divVerify);

	    var b4 = document.createElement("input");
	    b4.type = "button";
	    b4.value = "Not a patron";
	    b4.onclick = make_deverify_handler( requestId );
	    divVerify.appendChild(b4);

	    divResponses.appendChild(divVerify);
	}

	var b1 = document.createElement("input");
	b1.type = "button";
	b1.value = "Create ILL";
	b1.onclick = make_ILL_handler( requestId );
	if (!is_verified) {
	    b1.disabled = "disabled";
	}
	divResponses.appendChild(b1);
	
	var b2 = document.createElement("input");
	b2.type = "button";
	b2.value = "Do NOT create ILL";
	b2.onclick = make_noILL_handler( requestId );
	if (!is_verified) {
	    b2.disabled = "disabled";
	}
	divResponses.appendChild(b2);

	if (data.new_patron_requests[i].has_local_copy == 1) {
	    var p = document.createElement("p");
	    p.innerHTML = "Title held locally";
	    divResponses.appendChild(p);
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

function make_noILL_handler( requestId ) {
    return function() { noILL( requestId ) };
}

function noILL( requestId ) {
    var myRow=$("#pr"+requestId);
    var parms = {
	prid: requestId,
	lid: $("#lid").text(),
    }
    $.getJSON('/cgi-bin/decline-patron-request.cgi', parms,
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
	    $("#pr"+requestId).fadeOut(400, function() { $(this).remove(); }); // toast the row
	});
}


function make_ILL_handler( requestId ) {
    return function() { createILL( requestId ) };
}

function createILL( requestId ) {
    var myRow=$("#pr"+requestId);
    var parms = {
	prid: requestId,
	lid: $("#lid").text(),
    }
    $.getJSON('/cgi-bin/accept-patron-request.cgi', parms,
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
	    $("#pr"+requestId).fadeOut(400, function() { $(this).remove(); }); // toast the row
	});
}


function make_verify_handler( requestId ) {
    return function() { verify( requestId ) };
}

function verify( requestId ) {
    var myRow=$("#pr"+requestId);
    var parms = {
	prid: requestId,
	lid: $("#lid").text(),
    }
    $.getJSON('/cgi-bin/verify-patron-from-request.cgi', parms,
	      function(data){
//		  alert('change request status: '+data+'\n'+parms[0].status);
	      })
	.success(function() {
	    // get rid of the divVerify, and enable the buttons:
	    $("#divResponses"+requestId+" > div").hide();
	    $("#divResponses"+requestId).children().filter(":button").removeAttr("disabled");
	})
	.error(function() {
	    alert('error');
	})
	.complete(function() {
	    // slideUp doesn't work for <tr>
	    //$("#pr"+requestId).fadeOut(400, function() { $(this).remove(); }); // toast the row
	});
}


function make_deverify_handler( requestId ) {
    return function() { deverify( requestId ) };
}

function deverify( requestId ) {
    var myRow=$("#pr"+requestId);
    var parms = {
	prid: requestId,
	lid: $("#lid").text(),
    }

    // This doesn't exist yet!  What should happen when a library anti-verifies?

    $.getJSON('/cgi-bin/deverify-patron-from-request.cgi', parms,
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
	    $("#pr"+requestId).fadeOut(400, function() { $(this).remove(); }); // toast the row
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


