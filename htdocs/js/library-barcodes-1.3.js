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

    $('#datatable_barcodes').DataTable({
        "jQueryUI": true,
        "pagingType": "full_numbers",
        "info": true,
 	"ordering": true,
       	"dom": '<"H"Bfr>t<"F"ip>',
	buttons: [ 'copy', 'excel', 'pdf', 'print' ],
        "pageLength": 25,
        "lengthMenu": [[25, 50, 100, -1], [25, 50, 100, "All"]],
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
/*	
	"drawCallback": function( settings ) {
	    
	    // rows not on the current page are not in the DOM, and won't have
	    // the .edit class applied from the .complete callback.
	    // On a table redraw, those rows may get added, so we need to apply
	    // the class and make them editable.
	    $("tr").find("td:eq(2):not([class*='edit'])").addClass("edit");
	    $(".edit").editable( '/cgi-bin/update-library-barcode.cgi', {
		"callback": function( sValue, y ) {
		    var obj = jQuery.parseJSON( sValue );
		    dTable.cell( this ).data( obj.data );
		},
         	"submitdata": function ( value, settings ) {
		    var col = dTable.cell( this ).index().column;
		    // row_id holds oid and borrower oid separated by underscore: XX_YY
		    return {
			"row_id": this.parentNode.getAttribute('id'),
			"column": dTable.cell( this ).index().column
		    };
        	},
		"height": "14px",
		"select": true
	    });
	}
*/
    });

    var anOpenBarcodes = [];
    var dTable;
    $.getJSON('/cgi-bin/get-library-barcodes.cgi', {oid: $("#oid").text()},
              function(data){
                  build_table(data);
		  $("#waitDiv").hide();
		  $("#mylistDiv").show();
              })
	.success(function() {
	})
	.error(function() {
	    alert('error');
	})
	.complete(function() {
	    /* Apply the jEditable handlers to the table */
/*	    
            $("tr").find("td:eq(2)").addClass("edit");
	    $(".edit").editable( '/cgi-bin/update-library-barcode.cgi', {
	        "callback": function( sValue, y ) {
	            var obj = jQuery.parseJSON( sValue );
                    dTable.cell( this ).data( obj.data );
	        },
         	"submitdata": function ( value, settings ) {
                    var col = dTable.cell( this ).index().column;
	            // row_id holds oid and borrower oid separated by underscore: XX_YY
	            return {
		        "row_id": this.parentNode.getAttribute('id'),
			"column": dTable.cell( this ).index().column
		    };
        	},
	        "height": "14px",
	        "select": true
            });
*/
       });
});


function build_table( data ) {
    var t = $('#datatable_barcodes').DataTable();
    
    for (var i=0;i<data.barcodes.length;i++) {
	// this should match the fields in the template
	var rdata = [
            data.barcodes[i].oid,
            data.barcodes[i].borrower,
            data.barcodes[i].symbol,
            data.barcodes[i].org_name,
            data.barcodes[i].barcode
	];
	var rowNode = t.row.add( rdata ).draw().node();
	$(rowNode).attr("id",data.barcodes[i].oid+'_'+data.barcodes[i].borrower);
    }

    // make the last column editable
    // from https://datatables.net/reference/api/column%28%29.nodes%28%29
    t.column(-1).nodes().to$()      // Convert to a jQuery object
	.addClass( '.edit' );

    // from https://datatables.net/forums/discussion/27733/example-datatables-1-10-and-jeditable
    $( t.column(-1).nodes() ).editable( '/cgi-bin/update-library-barcode.cgi', {
	"callback": function( sValue, y ) {
	    var obj = jQuery.parseJSON( sValue );
	    t.cell( this ).data( obj.data ).draw();
	},
        "submitdata": function ( value, settings ) {
	    // row_id holds oid and borrower oid separated by underscore: XX_YY
            return {
		"row_id": $(this).closest('tr').attr('id'),
		"column": t.cell( this ).index().column
            };
        },
	"height": "25px",
	"select": true
    });
}

