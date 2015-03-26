// rotation-stats.js
/*
    fILL - Free/Open-Source Interlibrary Loan management system
    Copyright (C) 2012  Government of Manitoba

    rotation-stats.js is a part of fILL.

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
    myTable.setAttribute("id","enter-stats-table");
    myTable.className = myTable.className + " row-border";
    var tHead = myTable.createTHead();
    var row = tHead.insertRow(-1);
    var cell;
    // Can't just use:
    // cell = row.insertCell(-1); cell.innerHTML = "ID";
    // ...because insertCell inserts TD elements, and our CSS uses TH for header cells.
    
    cell = document.createElement("TH"); cell.innerHTML = "id"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "callno"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "title"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "author"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "barcode"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "received"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "number of circs"; row.appendChild(cell);
    
    var tFoot = myTable.createTFoot();
    row = tFoot.insertRow(-1);
    cell = row.insertCell(-1); cell.colSpan = "7"; cell.innerHTML = "You can print this list.";
    
    // explicit creation of TBODY element to make IE happy
    var tBody = document.createElement("TBODY");
    myTable.appendChild(tBody);
    
    for (var i=0;i<data.rotation.length;i++) 
    {
        row = tBody.insertRow(-1); row.id = 'item'+data.rotation[i].id;
        cell = row.insertCell(-1); cell.innerHTML = data.rotation[i].id;
        cell = row.insertCell(-1); cell.innerHTML = data.rotation[i].callno;
        cell = row.insertCell(-1); cell.innerHTML = data.rotation[i].title;
        cell = row.insertCell(-1); cell.innerHTML = data.rotation[i].author;
        cell = row.insertCell(-1); cell.innerHTML = data.rotation[i].barcode;
        cell = row.insertCell(-1); cell.innerHTML = data.rotation[i].timestamp;
        cell = row.insertCell(-1); 

	var divEnterStat = document.createElement("div");
	divEnterStat.id = 'divEnterStat'+data.rotation[i].id;

	var t1 = document.createElement("input");
	t1.type = "text";
//	t1.value = "0";
	t1.value = data.rotation[i].circs;
	t1.size = 5;
	var itemId = data.rotation[i].id;
	t1.id = "circstat"+itemId;
	t1.onchange = make_rotation_handler( itemId );
	divEnterStat.appendChild(t1);
	
	cell.appendChild( divEnterStat );
    }
    
    document.getElementById('mylistDiv').appendChild(myTable);
    
    $("#waitDiv").hide();
    $("#mylistDiv").show();
}

// Explanation of why we need a function to create the buttons' onclick handlers:
// http://www.webdeveloper.com/forum/archive/index.php/t-100584.html
// Short answer: scoping and closures

function make_rotation_handler( itemId ) {
    return function() { enter_stat( itemId ) };
}

function enter_stat( itemId ) {
    var myRow=$("#item"+itemId);
    var myCS=$("#circstat"+itemId);
//    alert('handling onChange event for id [' + itemId + '], circ stat is [' + myCS.val() + ']');
    var parms = {
	"id": itemId,
	"lid": $("#lid").text(),
	"circs": myCS.val(),
    };
    $.getJSON('/cgi-bin/set-rotation-circ-stat.cgi', parms,
	      function(data){
//		  alert('change request status: '+data+'\n'+parms[0].status);
	      })
	.success(function() {
	})
	.error(function() {
	    alert('error');
	})
	.complete(function() {
	    // slideUp doesn't work for <tr>
//	    $("#item"+itemId).fadeOut(400, function() { $(this).remove(); }); // toast the row
	});
}
