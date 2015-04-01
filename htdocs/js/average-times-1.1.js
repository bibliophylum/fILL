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
$('document').ready(function(){

    $(function() {
        $.getJSON('/cgi-bin/get-average-times.cgi', {},
                  function(data){
                      build_table(data);
		  })
            .success(function() {
		//alert('success');
	    })
	    .error(function() {
		alert('error');
	    })
	    .complete(function() {
		$('#average-times-table').DataTable({
		    "jQueryUI": true,
		    "pagingType": "full_numbers",
		    "info": true,
		    "oerdering": true,
		    "dom": '<"H"Tfr>t<"F"ili>',
		    "pageLength": -1,
		    "lengthMenu": [[10, 25, 50, -1], [10, 25, 50, "All"]],
		    "tableTools": {
			"sSwfPath": "/plugins/DataTables-1.10.2/extensions/TableTools/swf/copy_csv_xls_pdf.swf",
			"aButtons": [
			    "copy", "csv", "xls", "pdf", "print",
			    {
				"sExtends":    "collection",
				"sButtonText": "Save",
				"aButtons":    [ "csv", "xls", "pdf" ]
			    }
			]
		    },
		    "autoWidth": false
		});
		
	    });
	
    });
    
});

function build_table( data ) {
//    alert( 'in build_table' );

    var myTable = document.createElement("table");
    myTable.setAttribute("id","average-times-table");
    myTable.className = myTable.className + " cell-border";
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
    $("#waitDiv").hide();
    $("#mylistDiv").show();
}

function build_rows( tBody, data ) {
    for (var i=0;i<data.libraries.length;i++) 
    {
	// IE displays null values as 'null' rather than blank.
	for (var propt in data.libraries[i]) {
	    if (data.libraries[i][propt] == null) {
		data.libraries[i][propt] = '';
	    }
	}

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



