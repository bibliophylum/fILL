// patrons-list.js
/*
    fILL - Free/Open-Source Interlibrary Loan management system
    Copyright (C) 2012  Government of Manitoba

    patrons-list.js is a part of fILL.

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
function build_table_orig( data ) {
    for (var i=0;i<data.patrons.length;i++) {
	data.patrons[i].actions = "Click to change password"; // add the 'actions' column
	var ai = oTable.fnAddData( data.patrons[i] );
	var n = oTable.fnSettings().aoData[ ai[0] ].nTr;
	var oData = oTable.fnGetData( n );
	n.setAttribute('id', n.cells[0].innerHTML);

    }
    $("#waitDiv").hide();
    $("#mylistDiv").show();
}

function build_table( data ) {
    var myTable = document.createElement("table");
    myTable.setAttribute("id","datatable_patrons");
    myTable.className = myTable.className + " row-border";
    var tHead = myTable.createTHead();
    var row = tHead.insertRow(-1);
    var cell;
    // Can't just use:
    // cell = row.insertCell(-1); cell.innerHTML = "ID";
    // ...because insertCell inserts TD elements, and our CSS uses TH for header cells.
    
    cell = document.createElement("TH"); cell.innerHTML = "pid"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Name"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Card"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Username"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Email address"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Verified?"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Enabled?"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Last login"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Number of requests"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Change password"; row.appendChild(cell);
    
    var tFoot = myTable.createTFoot();
    row = tFoot.insertRow(-1);
    cell = row.insertCell(-1); cell.colSpan = "5"; cell.innerHTML = " ";
    
    // explicit creation of TBODY element to make IE happy
    var tBody = document.createElement("TBODY");
    myTable.appendChild(tBody);
    
    for (var i=0;i<data.patrons.length;i++) 
    {
        row = tBody.insertRow(-1); row.id = 'pid'+data.patrons[i].pid;
        cell = row.insertCell(-1); cell.innerHTML = data.patrons[i].pid;
        cell = row.insertCell(-1); cell.innerHTML = data.patrons[i].name;
        cell = row.insertCell(-1); cell.innerHTML = data.patrons[i].card;
        cell = row.insertCell(-1); cell.innerHTML = data.patrons[i].username;
        cell = row.insertCell(-1); cell.innerHTML = data.patrons[i].email_address;
        cell = row.insertCell(-1); cell.innerHTML = data.patrons[i].is_verified;
        cell = row.insertCell(-1); cell.innerHTML = data.patrons[i].is_enabled;
        cell = row.insertCell(-1); cell.innerHTML = data.patrons[i].last_login;
        cell = row.insertCell(-1); cell.innerHTML = data.patrons[i].ill_requests;
        cell = row.insertCell(-1); cell.innerHTML = "Click to change password";
    }
    
    document.getElementById('mylistDiv').appendChild(myTable);
    
    $("#waitDiv").hide();
    $("#mylistDiv").show();
}
