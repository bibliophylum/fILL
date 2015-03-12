// library_barcodes.js
/*
    fILL - Free/Open-Source Interlibrary Loan management system
    Copyright (C) 2012  Government of Manitoba

    library_barcodes.js is a part of fILL.

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

    var anOpenBarcodes = [];
    var dTable;
    $.getJSON('/cgi-bin/get-library-barcodes.cgi', {lid: $("#lid").text()},
              function(data){
                  build_table(data);
		  
                  dTable = $('#datatable_barcodes').DataTable({
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
                      "columnDefs": [ {
			  "targets": [0,1],
			  "visible": false
                      }],
                      "autoWidth": false,
                      "initComplete": function() {
			  // this handles a bug(?) in this version of datatables;
			  // hidden columns caused the table width to be set to 100px, not 100%
			  $("#datatable_barcodes").css("width","100%");
                      },
		      "drawCallback": function( settings ) {
			  // rows not on the current page are not in the DOM, and won't have
			  // the .edit class applied from the .complete callback.
			  // On a table redraw, those rows may get added, so we need to apply
			  // the class and make them editable.
			  $("tr").find("td:eq(2):not([class*='edit'])").addClass("edit");
			  $(".edit").editable( '/cgi-bin/update-library-barcode.cgi', {
			      "callback": function( sValue, y ) {
				  var obj = jQuery.parseJSON( sValue );
				  //dTable.cell( this ).data( obj.data ).draw();  // .draw() does a full re-sort/re-filter; not needed.
				  dTable.cell( this ).data( obj.data );
			      },
         		      "submitdata": function ( value, settings ) {
				  var col = dTable.cell( this ).index().column;
				  // row_id holds lid and borrower lid separated by underscore: XX_YY
				  return {
				      "row_id": this.parentNode.getAttribute('id'),
				      "column": dTable.cell( this ).index().column
				  };
        		      },
			      "height": "14px",
			      "select": true
			  });
		      }
                });
           })
	.success(function() {
	    //alert('success');
	})
	.error(function() {
	    alert('error');
	})
	.complete(function() {
            //alert('ajax complete');
	    
	    /* Apply the jEditable handlers to the table */
            $("tr").find("td:eq(2)").addClass("edit");
	    $(".edit").editable( '/cgi-bin/update-library-barcode.cgi', {
	        "callback": function( sValue, y ) {
	            var obj = jQuery.parseJSON( sValue );
                    //dTable.cell( this ).data( obj.data ).draw();
                    dTable.cell( this ).data( obj.data );
	        },
         	"submitdata": function ( value, settings ) {
                    var col = dTable.cell( this ).index().column;
	            // row_id holds lid and borrower lid separated by underscore: XX_YY
	            return {
		        "row_id": this.parentNode.getAttribute('id'),
			"column": dTable.cell( this ).index().column
		    };
        	},
	        "height": "14px",
	        "select": true
            });

       });
});



function build_table_orig( data ) {
    for (var i=0;i<data.barcodes.length;i++) {
//	alert( data.barcodes[i].library );
	var ai = oTable.fnAddData( data.barcodes[i] );
	var n = oTable.fnSettings().aoData[ ai[0] ].nTr;
	var oData = oTable.fnGetData( n );
    }
//    oTable.fnSetColumnVis(1, false);
//    oTable.fnSetColumnVis(2, false);
    $("#waitDiv").hide();
    $("#mylistDiv").show();
}

function build_table( data ) {
    var myTable = document.createElement("table");
    myTable.setAttribute("id","datatable_barcodes");
    myTable.className = myTable.className + " row-border";
    var tHead = myTable.createTHead();
    var row = tHead.insertRow(-1);
    var cell;
    // Can't just use:
    // cell = row.insertCell(-1); cell.innerHTML = "ID";
    // ...because insertCell inserts TD elements, and our CSS uses TH for header cells.
    
    cell = document.createElement("TH"); cell.innerHTML = "lid"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "borrower"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "symbol"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "library"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "barcode"; row.appendChild(cell);
    
    var tFoot = myTable.createTFoot();
    row = tFoot.insertRow(-1);
    cell = row.insertCell(-1); cell.colSpan = "5"; cell.innerHTML = "Click on the barcode column to enter the barcode from your ILS.";
    
    // explicit creation of TBODY element to make IE happy
    var tBody = document.createElement("TBODY");
    myTable.appendChild(tBody);
    
    for (var i=0;i<data.barcodes.length;i++) 
    {
        row = tBody.insertRow(-1); row.id = data.barcodes[i].lid+'_'+data.barcodes[i].borrower;
        cell = row.insertCell(-1); cell.innerHTML = data.barcodes[i].lid;
        cell = row.insertCell(-1); cell.innerHTML = data.barcodes[i].borrower;
        cell = row.insertCell(-1); cell.innerHTML = data.barcodes[i].name;
        cell = row.insertCell(-1); cell.innerHTML = data.barcodes[i].library;
        cell = row.insertCell(-1); cell.innerHTML = data.barcodes[i].barcode;
    }
    
    document.getElementById('mylistDiv').appendChild(myTable);
    
    $("#waitDiv").hide();
    $("#mylistDiv").show();
}

