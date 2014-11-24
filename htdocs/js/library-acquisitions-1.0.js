// library_acquisitions.js
/*
    fILL - Free/Open-Source Interlibrary Loan management system
    Copyright (C) 2012  Government of Manitoba

    library_acquisitions.js is a part of fILL.

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
    myTable.setAttribute("id","datatable_acquisitions");
    myTable.className = myTable.className + " row-border";
    var tHead = myTable.createTHead();
    var row = tHead.insertRow(-1);
    var cell;
    // Can't just use:
    // cell = row.insertCell(-1); cell.innerHTML = "ID";
    // ...because insertCell inserts TD elements, and our CSS uses TH for header cells.
    
    cell = document.createElement("TH"); cell.innerHTML = "lid"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "title"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "author"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "isbn"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "pubdate"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "medium"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "date added"; row.appendChild(cell);
    
    var tFoot = myTable.createTFoot();
    row = tFoot.insertRow(-1);
    cell = row.insertCell(-1); cell.colSpan = "7"; cell.innerHTML = "You added these items from the New Patron Requests and Unfilled tables.";
    
    // explicit creation of TBODY element to make IE happy
    var tBody = document.createElement("TBODY");
    myTable.appendChild(tBody);
    
    for (var i=0;i<data.acquisitions.length;i++) 
    {
        row = tBody.insertRow(-1); row.id = 'acq'+data.acquisitions[i].lid;
        cell = row.insertCell(-1); cell.innerHTML = data.acquisitions[i].lid;
        cell = row.insertCell(-1); cell.innerHTML = data.acquisitions[i].title;
        cell = row.insertCell(-1); cell.innerHTML = data.acquisitions[i].author;
        cell = row.insertCell(-1); cell.innerHTML = data.acquisitions[i].isbn;
        cell = row.insertCell(-1); cell.innerHTML = data.acquisitions[i].pubdate;
        cell = row.insertCell(-1); cell.innerHTML = data.acquisitions[i].medium;
        cell = row.insertCell(-1); cell.innerHTML = data.acquisitions[i].ts;
    }
    
    document.getElementById('mylistDiv').appendChild(myTable);
    
    $("#waitDiv").hide();
    $("#mylistDiv").show();
}

function ajax_clear_acquisitions() {
    $.getJSON('/cgi-bin/clear-acquisitions.cgi', {lid: $("#lid").text()},
	      function(data){
	      })
    .success(function() {
	$('#datatable_acquisitions').DataTable().clear().draw();
    })
    .error(function() {
    })
    .complete(function() {
    });
}

function clear_acquisitions() {
    $('<div></div>').appendTo('body')
	.html('<div><h6>Are you sure?</h6><p>This will permanently remove these items from the wish list.</p></div>')
	.dialog({
            modal: true,
            title: 'Clear the wish list',
            zIndex: 10000,
            autoOpen: true,
            resizable: false,
            buttons: [
	        {
	            text: "Yes",
		    //                            "class": "library-style",
	            open: function() { 
	                $(this).addClass('library-style');
	                $(this).removeClass('ui-state-default');
	            },
	            click: function () {
                        ajax_clear_acquisitions();
                        $(this).dialog("close");
                    }
                },
                {
	            text: "No",
		    //	                    "class": "library-style",
	            open: function() { 
	                $(this).addClass('library-style');
	                $(this).removeClass('ui-state-default');
	            },
	            click: function () {
                        $(this).dialog("close");
                    }
                }
            ],
            close: function (event, ui) {
                $(this).remove();
            }
        });
}
