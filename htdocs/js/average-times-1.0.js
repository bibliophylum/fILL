// average=times.js
/*
    fILL - Free/Open-Source Interlibrary Loan management system
    Copyright (C) 2012  Government of Manitoba

    average-times.js is a part of fILL.

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
    
    cell = document.createElement("TH"); cell.innerHTML = "Lender"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Borrower Request to Lender Respond (days)"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Lender Will-Supply to Lender Shipped (hours)"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Lender Shipped to Borrower Received (days)"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Borrower Renew to Lender Renew-Answer (days)"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Borrower Received to Borrower Returned (days)"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Borrower Returned to Lender Check-in (days)"; row.appendChild(cell);
    
    var tFoot = myTable.createTFoot();
    row = tFoot.insertRow(-1);
    cell = row.insertCell(-1); cell.colSpan = "7"; cell.innerHTML = "Average time per library";
    
    // explicit creation of TBODY element to make IE happy
    var tBody = document.createElement("TBODY");
    myTable.appendChild(tBody);
    // this needs to happen before the .getJSON call (which might take a moment)
    // to ensure that the datatable-ness in respond.tmpl gets applied
    document.getElementById('mylistDiv').appendChild(myTable);

    build_rows( tBody, data );
    toggleLayer("waitDiv");
    toggleLayer("mylistDiv");
}

function build_rows( tBody, data ) {
    for (var i=0;i<data.libraries.length;i++) 
    {
	row = tBody.insertRow(-1); row.id = 'lid'+data.libraries[i].lid;
	cell = row.insertCell(-1); cell.innerHTML = data.libraries[i].library;
	cell = row.insertCell(-1); cell.innerHTML = data.libraries[i].request_to_response_days;
	cell = row.insertCell(-1); cell.innerHTML = data.libraries[i].will_supply_to_shipped_hours;
	cell = row.insertCell(-1); cell.innerHTML = data.libraries[i].shipped_to_received_days;
	cell = row.insertCell(-1); cell.innerHTML = data.libraries[i].renew_to_renew_answer_days;
	cell = row.insertCell(-1); cell.innerHTML = data.libraries[i].received_to_returned_days;
	cell = row.insertCell(-1); cell.innerHTML = data.libraries[i].returned_to_checked_in_days;
    }	

    $("#lid-1 > td").each(function() {
	$( this ).attr('class','average');
    });

    // self library id number is in $("#lid") in page header:
    $("#lid"+$("#lid").text()+" > td").each(function() {
	$( this ).attr('class','highlight');
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


