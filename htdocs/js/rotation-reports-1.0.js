// rotation-reports.js
/*
    fILL - Free/Open-Source Interlibrary Loan management system
    Copyright (C) 2012  Government of Manitoba

    rotation-reports.js is a part of fILL.

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
function build_received_counts_table( data ) {
    var myTable = document.createElement("table");
    myTable.setAttribute("id","received-circ-counts-table");
    var tHead = myTable.createTHead();
    var row = tHead.insertRow(-1);
    var cell;
    // Can't just use:
    // cell = row.insertCell(-1); cell.innerHTML = "ID";
    // ...because insertCell inserts TD elements, and our CSS uses TH for header cells.
    
    cell = document.createElement("TH"); cell.innerHTML = "library"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "symbol"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "count"; row.appendChild(cell);
    
    var tFoot = myTable.createTFoot();
    row = tFoot.insertRow(-1);
    cell = row.insertCell(-1); cell.colSpan = "3"; cell.innerHTML = "";
    
    // explicit creation of TBODY element to make IE happy
    var tBody = document.createElement("TBODY");
    myTable.appendChild(tBody);
    
    for (var i=0;i<data.rotations_received.length;i++) 
    {
        row = tBody.insertRow(-1); row.id = 'rrc'+data.rotations_received[i].symbol;
        cell = row.insertCell(-1); cell.innerHTML = data.rotations_received[i].now_at;
        cell = row.insertCell(-1); cell.innerHTML = data.rotations_received[i].symbol;
        cell = row.insertCell(-1); cell.innerHTML = data.rotations_received[i].count;
    }
    
    document.getElementById('mylistDiv').appendChild(myTable);
    
    $("#waitDiv").hide();
    $("#mylistDiv").show();
}

function build_item_circ_counts_table( data ) {
    var myTable = document.createElement("table");
    myTable.setAttribute("id","item-circ-counts-table");
    var tHead = myTable.createTHead();
    var row = tHead.insertRow(-1);
    var cell;
    // Can't just use:
    // cell = row.insertCell(-1); cell.innerHTML = "ID";
    // ...because insertCell inserts TD elements, and our CSS uses TH for header cells.
    
    cell = document.createElement("TH"); cell.innerHTML = "library"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "name"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "ts_start"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "ts_end"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "title"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "callno"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "barcode"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "circs"; row.appendChild(cell);
    
    var tFoot = myTable.createTFoot();
    row = tFoot.insertRow(-1);
    cell = row.insertCell(-1); cell.colSpan = "8"; cell.innerHTML = "";
    
    // explicit creation of TBODY element to make IE happy
    var tBody = document.createElement("TBODY");
    myTable.appendChild(tBody);
    
    for (var i=0;i<data.rotations_item_circ_counts.length;i++) 
    {
        row = tBody.insertRow(-1); row.id = 'ric'+data.rotations_item_circ_counts[i].barcode;
        cell = row.insertCell(-1); cell.innerHTML = data.rotations_item_circ_counts[i].library;
        cell = row.insertCell(-1); cell.innerHTML = data.rotations_item_circ_counts[i].name;
        cell = row.insertCell(-1); cell.innerHTML = data.rotations_item_circ_counts[i].ts_start;
        cell = row.insertCell(-1); cell.innerHTML = data.rotations_item_circ_counts[i].ts_end;
        cell = row.insertCell(-1); cell.innerHTML = data.rotations_item_circ_counts[i].title;
        cell = row.insertCell(-1); cell.innerHTML = data.rotations_item_circ_counts[i].callno;
        cell = row.insertCell(-1); cell.innerHTML = data.rotations_item_circ_counts[i].barcode;
        cell = row.insertCell(-1); cell.innerHTML = data.rotations_item_circ_counts[i].circs;
    }
    
    document.getElementById('mylistDiv').appendChild(myTable);
    
    $("#waitDiv").hide();
    $("#mylistDiv").show();
}
