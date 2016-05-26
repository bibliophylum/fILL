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

    $('#overdue-table').DataTable({
        "jQueryUI": true,
        "pagingType": "full_numbers",
        "info": true,
        "ordering": true,
        "dom": '<"H"Bfr>t<"F"ip>',
	buttons: [ 'copy', 'excel', 'pdf', 'print' ],
        "columnDefs": [ {
            "targets": [0,1,2,6],
            "visible": false
        } ],
        "initComplete": function() {
            // this handles a bug(?) in this version of datatables;
            // hidden columns caused the table width to be set to 100px, not 100%
            $("#overdue-table").css("width","100%");

	    $("#overdue-table").DataTable().page.len( parseInt($("#table_rows_per_page").text(),10));
        }
    });
    
    $.getJSON('/cgi-bin/get-overdue-list.cgi', {oid: $("#oid").text()},
              function(data){
		  build_table(data);
		  $("#waitDiv").hide();
		  $("#mylistDiv").show();
              })
	.success(function() {
        })
	.error(function() {
        })
	.complete(function() { 
        });
    
    $(function() {
        update_menu_counters( $("#oid").text() );
    });

});

function build_table( data ) {
    var t = $('#overdue-table').DataTable();
    
    for (var i=0;i<data.overdue.length;i++) {

	// this should match the fields in the template
	var rdata = [
            data.overdue[i].gid,
            data.overdue[i].cid,
            data.overdue[i].id,
            data.overdue[i].title,
            data.overdue[i].author,
            data.overdue[i].from,
            data.overdue[i].msg_from,
            data.overdue[i].ts,
            data.overdue[i].due_date,
            data.overdue[i].patron_barcode
	];
	var rowNode = t.row.add( rdata ).draw().node();
	$(rowNode).attr("id",'req'+data.overdue[i].id);
	// the :eq selector looks at *visible* nodes....
	$(rowNode).children(":eq(2)").attr("title",data.overdue[i].library);

	borrowerNotes_insertChild( t, rowNode,
				   data.overdue[i].borrower_internal_note,
				   "datatable-detail"
				 );
    }
    borrowerNotes_makeEditable();
}

