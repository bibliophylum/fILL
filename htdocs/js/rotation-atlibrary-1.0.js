// rotation-atlibrary.js
/*
    fILL - Free/Open-Source Interlibrary Loan management system
    Copyright (C) 2012  Government of Manitoba

    rotation-atlibrary.js is a part of fILL.

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
    myTable.setAttribute("id","at-my-library");
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
    
    var tFoot = myTable.createTFoot();
    row = tFoot.insertRow(-1);
    cell = row.insertCell(-1); cell.colSpan = "6"; cell.innerHTML = "You can print this list.";
    
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
	var img = document.createElement('img');
	img.src = "data:image/png;base64,"+data.rotation[i].barcode_image
	cell.appendChild(img);

        cell = row.insertCell(-1); cell.innerHTML = data.rotation[i].timestamp;
    }
    
    document.getElementById('mylistDiv').appendChild(myTable);
    
    toggleLayer("waitDiv");
    toggleLayer("mylistDiv");
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


