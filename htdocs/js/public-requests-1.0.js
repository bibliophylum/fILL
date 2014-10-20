// public-requests.js
/*
    fILL - Free/Open-Source Interlibrary Loan management system
    Copyright (C) 2012  Government of Manitoba

    public-requests.js is a part of fILL.

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
    for (var i=0;i<data.active.length;i++) {
	var ai = oTable_borrowing.fnAddData( data.active[i], false );
    }
    oTable_borrowing.fnDraw();

    $("#waitDiv").hide();
    $("#mylistDiv").show();
}

function build_table( data ) {
    var myTable = document.createElement("table");
    myTable.setAttribute("id","datatable_borrowing");
    var tHead = myTable.createTHead();
    var row = tHead.insertRow(-1);
    var cell;
    // Can't just use:
    // cell = row.insertCell(-1); cell.innerHTML = "ID";
    // ...because insertCell inserts TD elements, and our CSS uses TH for header cells.
    
    cell = document.createElement("TH"); cell.innerHTML = "cid"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Title"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Author"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Lender"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Status"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Details"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Status Updated"; row.appendChild(cell);
    
    var tFoot = myTable.createTFoot();
    row = tFoot.insertRow(-1);
    cell = row.insertCell(-1); cell.colSpan = "6"; cell.innerHTML = " ";
    
    // explicit creation of TBODY element to make IE happy
    var tBody = document.createElement("TBODY");
    myTable.appendChild(tBody);
    
    for (var i=0;i<data.active.length;i++) 
    {
        row = tBody.insertRow(-1); row.id = 'cid'+data.active[i].cid;
        cell = row.insertCell(-1); cell.innerHTML = data.active[i].cid;
        cell = row.insertCell(-1); cell.innerHTML = data.active[i].title;
        cell = row.insertCell(-1); cell.innerHTML = data.active[i].author;
        cell = row.insertCell(-1); cell.innerHTML = data.active[i].lender;
        cell = row.insertCell(-1); cell.innerHTML = data.active[i].status;
        cell = row.insertCell(-1); cell.innerHTML = data.active[i].libraries_tried;
        cell = row.insertCell(-1); cell.innerHTML = data.active[i].ts;
    }
    
    document.getElementById('mylistDiv').appendChild(myTable);
    
    $("#waitDiv").hide();
    $("#mylistDiv").show();
}

function fnFormatDetails( oTable, nTr )
{
    var oData = oTable.fnGetData( nTr );
    $.getJSON('/cgi-bin/get-current-request-details.cgi', { "cid": oData.cid },
	      function(data){
		  //alert('first success');
	      })
	.success(function() {
	    //alert('success');
	})
	.error(function() {
	    alert('error');
	})
	.complete(function(jqXHRObject) {
	    var data = $.parseJSON(jqXHRObject.responseText)
	    var sOut;
	    var numDetails = data.request_details.length; 
	    sOut = '<div class="innerDetails">'+
		'<table id="gradient-style" cellpadding="5" cellspacing="0" border="0" style="padding-left:50px;">'+
		'<thead><th>Request ID</th><th>Timestamp</th><th>Msg from</th><th>Msg to</th><th>Status</th><th>Extra information</th></thead>';
	    for (var i = 0; i < numDetails; i++) {
		var detRow = '<tr>'+
		    '<td>'+data.request_details[i].request_id+'</td>'+
		    '<td>'+data.request_details[i].ts+'</td>'+
		    '<td>'+data.request_details[i].from+'</td>'+
		    '<td>'+data.request_details[i].to+'</td>'+
		    '<td>'+data.request_details[i].status+'</td>'+
		    '<td>'+data.request_details[i].message+'</td>'+
		    '</tr>';
		sOut=sOut+detRow;
	    }
	    sOut = sOut+'</table>'+'</div>';
            var nDetailsRow = oTable.fnOpen( nTr, sOut, 'details' );
	    $(nDetailsRow).attr('detail','conversation');
            $('div.innerDetails', nDetailsRow).slideDown();

	});
}
