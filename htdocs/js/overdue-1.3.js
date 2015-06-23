// overdue.js
/*
    fILL - Free/Open-Source Interlibrary Loan management system
    Copyright (C) 2012  Government of Manitoba

    overdue.js is a part of fILL.

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

    $.getJSON('/cgi-bin/get-overdue-list.cgi', {oid: $("#oid").text()},
            function(data){
                //alert (data.overdue[0].id+" "+data.overdue[0].title+" "+data.overdue[0].author+" "+data.overdue[0].ts+" "+data.overdue[0].due_date+" "+data.overdue[0].patron_barcode); //further debug
                build_table(data);

                $('#overdue-table').DataTable({
                       "jQueryUI": true,
                       "pagingType": "full_numbers",
                       "info": true,
                       "ordering": true,
                       "dom": '<"H"Tfr>t<"F"ip>',
                       // TableTools requires Flash version 10...
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
                       "columnDefs": [ {
                           "targets": [0,1,2,6],
                           "visible": false
                       } ],
                      "initComplete": function() {
                          // this handles a bug(?) in this version of datatables;
                          // hidden columns caused the table width to be set to 100px, not 100%
                          $("#overdue-table").css("width","100%");
                      }
                  });
           });

    $(function() {
           update_menu_counters( $("#oid").text() );
    });

});

function build_table( data ) {
    //alert( 'in build_table' );
    var myTable = document.createElement("table");
    myTable.setAttribute("id","overdue-table");
    myTable.className = myTable.className + " row-border";
    var tHead = myTable.createTHead();
    var row = tHead.insertRow(-1);
    var cell;
    // Can't just use:
    // cell = row.insertCell(-1); cell.innerHTML = "ID";
    // ...because insertCell inserts TD elements, and our CSS uses TH for header cells.
    
    cell = document.createElement("TH"); cell.innerHTML = "gid"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "cid"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "ID"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Title"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Author"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Borrowed from"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Borrowed from (ID)"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Last update"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Due date"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Patron"; row.appendChild(cell);
    
    var tFoot = myTable.createTFoot();
    row = tFoot.insertRow(-1);
    cell = row.insertCell(-1); cell.colSpan = "10"; cell.innerHTML = "These items are now overdue.";
    
    // explicit creation of TBODY element to make IE happy
    var tBody = document.createElement("TBODY");
    myTable.appendChild(tBody);
    
    for (var i=0;i<data.overdue.length;i++) 
    {
        row = tBody.insertRow(-1); row.id = 'req'+data.overdue[i].id;
        cell = row.insertCell(-1); cell.innerHTML = data.overdue[i].gid;
        cell = row.insertCell(-1); cell.innerHTML = data.overdue[i].cid;
        cell = row.insertCell(-1); cell.innerHTML = data.overdue[i].id;
        cell = row.insertCell(-1); cell.innerHTML = data.overdue[i].title;
        cell = row.insertCell(-1); cell.innerHTML = data.overdue[i].author;
        cell = row.insertCell(-1); cell.innerHTML = data.overdue[i].from; cell.setAttribute('title', data.overdue[i].library);
        cell = row.insertCell(-1); cell.innerHTML = data.overdue[i].msg_from;
        cell = row.insertCell(-1); cell.innerHTML = data.overdue[i].ts;
        cell = row.insertCell(-1); cell.innerHTML = data.overdue[i].due_date;
        cell = row.insertCell(-1); cell.innerHTML = data.overdue[i].patron_barcode;
//        cell = row.insertCell(-1); 
//
//	var divResponses = document.createElement("div");
//	divResponses.id = 'divResponses'+data.overdue[i].id;
//
//	var b1 = document.createElement("input");
//	b1.type = "button";
//	b1.value = "Print overdue notice";
//	var requestId = data.overdue[i].id;
//	b1.onclick = make_overdue_handler( requestId );
//	divResponses.appendChild(b1);
//	
//	cell.appendChild( divResponses );
    }
    
    document.getElementById('mylistDiv').appendChild(myTable);
    
    $("#waitDiv").hide();
    $("#mylistDiv").show();
}

// Explanation of why we need a function to create the buttons' onclick handlers:
// http://www.webdeveloper.com/forum/archive/index.php/t-100584.html
// Short answer: scoping and closures

function make_overdue_handler( requestId ) {
    return function() { overdue( requestId ) };
}

function overdue( requestId ) {
    var myRow=$("#req"+requestId);
    var nTr = myRow[0]; // convert jQuery object to DOM
    var oTable = $('#overdue-table').dataTable();
    var aPos = oTable.fnGetPosition( nTr );
    var msg_to = oTable.fnGetData( aPos )[6]; // 7th column (0-based!), hidden or not

    var parms = {
	"reqid": requestId,
	"msg_to": msg_to,
	"oid": $("#oid").text(),
	"status": "Renew",
	"message": ""
    };
    $.getJSON('/cgi-bin/change-request-status.cgi', parms,
	      function(data){
//		  alert('change request status: '+data+'\n'+parms[0].status);
	      })
	.success(function() {
	    // alert('success');
	    // print slip (single) / add to slip page (multi) / do nothing (none)
	})
	.error(function() {
	    alert('error');
	})
	.complete(function() {
	    // slideUp doesn't work for <tr>
	    $("#req"+requestId).fadeOut(400, function() { $(this).remove(); }); // toast the row
	});
}
