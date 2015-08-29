// report-borrowers-lenders.js
/*
    fILL - Free/Open-Source Interlibrary Loan management system
    Copyright (C) 2012  Government of Manitoba

    report-borrowers-lenders.js is a part of fILL.

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

    $("#year").val( new Date().getFullYear() );
    $("#month").hide();

    $("#dateButton").on("click", function() {
	$("#mylistDiv").hide();
	$("#waitDiv").show();
        requery();
	$("#waitDiv").hide();
	$("#mylistDiv").show();
    });

    $('input[type=radio][name=mtype]').change(function() {
        if (this.value == 'one') {
            $("#month").show();
        } else {
	    $("#month").hide();
        }
    });

    $(function() {
	$("#mylistDiv").hide();
	$("#waitDiv").show();
	//alert( $("#year").text() );

	create_table();

	$("#waitDiv").hide();
	$("#mylistDiv").show();
    });

});

function create_table() {
    var parms = { 
	oid: $("#oid").text(),
	year: $("#year").val(),
	month: $("#month").val(),
	mtype: $('input[name=mtype]:checked', '#dateForm').val()
    }

    //alert("parms\noid: "+parms.oid+"\nyear: "+parms.year+"\nmonth: "+parms.month+"\nmtype: "+parms.mtype);
    
    $.getJSON('/cgi-bin/reports/borrowing-from-lending-to-by-year.cgi',
	      parms,
	      function(data){
		  build_table(parms,data);  // builds to $('#report') in $('#mylistDiv')
	      })
	.success(function() {
	    //alert('success');
	})
	.error(function() {
	    alert('error');
	})
	.complete(function() {
	    
	    $('#report').DataTable({
		"jQueryUI": true,
		"pagingType": "full_numbers",
		"info": true,
      		"ordering": true,
		"dom": '<"H"Tfr>t<"F"ip>',
		"pageLength": 25,
		"lengthMenu": [[25, 50, 100, -1], [25, 50, 100, "All"]],
		"tableTools": {
		    "sSwfPath": "/plugins/DataTables-1.10.2/extensions/TableTools/swf/copy_csv_xls_pdf.swf"
		},
		"order": [[0,"asc"],[1,"asc"]],
		"autoWidth": true,
		"scrollX": false, 
		"initComplete": function() {
		    // this handles a bug(?) in this version of datatables;
		    // hidden columns caused the table width to be set to 100px, not 100%
		    $("#report").css("width","100%");
		}
	    });
	});
}

function requery() {
    $("#report").DataTable().destroy();
    $("#mylistDiv").empty();

    create_table();
}

function build_table( parms, data ) {
    //alert( 'in build_table' );

    var myTable = document.createElement("table");
    myTable.setAttribute("id","report");
    myTable.className = myTable.className + " cell-border";
    var tHead = myTable.createTHead();
    var row = tHead.insertRow(-1);
    var cell;
    // Can't just use:
    // cell = row.insertCell(-1); cell.innerHTML = "ID";
    // ...because insertCell inserts TD elements, and our CSS uses TH for header cells.
    
    cell = document.createElement("TH"); 
    cell.colSpan = "4"; 
    cell.innerHTML = "Borrowed from / Loaned to report, "+parms.year; 
    if (parms.mtype == 'one') {
	cell.innerHTML += "-" + parms.month;
    } else if (parms.mtype == 'all') {
	cell.innerHTML += ", all months.";
    } else if (parms.mtype == 'none') {
	cell.innerHTML += " Summary.";
    }
    row.appendChild(cell);
    row = tHead.insertRow(-1);

    cell = document.createElement("TH"); cell.innerHTML = "Period"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Library"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "We borrowed"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "We loaned"; row.appendChild(cell);
    
    var tFoot = myTable.createTFoot();
    row = tFoot.insertRow(-1);
    cell = row.insertCell(-1); cell.colSpan = "4"; cell.innerHTML = "Libraries we borrowed from / loaned to";
    
    // explicit creation of TBODY element to make IE happy
    var tBody = document.createElement("TBODY");
    myTable.appendChild(tBody);
    // this needs to happen before the .getJSON call (which might take a moment)
    // to ensure that the datatable-ness in respond.tmpl gets applied
    document.getElementById('mylistDiv').appendChild(myTable);

    build_rows( tBody, data );
}

function build_rows( tBody, data ) {
    //alert("in build_rows");
    for (var i=0;i<data.report.length;i++) 
    {
	// IE displays null values as 'null' rather than blank.
	for (var propt in data.report[i]) {
	    if (data.report[i][propt] == null) {
		data.report[i][propt] = '';
	    }
	}

	row = tBody.insertRow(-1); row.id = 'oid'+data.report[i].oid;
	cell = row.insertCell(-1); cell.innerHTML = data.report[i].period;
	cell = row.insertCell(-1); cell.innerHTML = data.report[i].org_name;
	cell = row.insertCell(-1); cell.innerHTML = data.report[i].we_borrowed;
	cell = row.insertCell(-1); cell.innerHTML = data.report[i].we_loaned;
    }	
}

