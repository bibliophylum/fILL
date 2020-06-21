// lend_overdue.js
/*
    fILL - Free/Open-Source Interlibrary Loan management system
    Copyright (C) 2012  Government of Manitoba

    lend_overdue.js is a part of fILL.

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
	"order": [[3,"asc"]],
	"bSortClasses": false,
        "dom": '<"H"Bfr>t<"F"ip>',
	buttons: [ 'copy', 'excel', 'pdf', 'print' ],
        "columnDefs": [ {
            "targets": [0,1,2,4],
            "visible": false
        } ],
        "initComplete": function() {
            // this handles a bug(?) in this version of datatables;
            // hidden columns caused the table width to be set to 100px, not 100%
            $("#overdue-table").css("width","100%");

	    $("#overdue-table").DataTable().page.len( parseInt($("#table_rows_per_page").text(),10));
        }
    });

    $.getJSON('/cgi-bin/get-lend-overdue-list.cgi', {oid: $("#oid").text()},
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

	//var divResponses = create_action_buttons( data, i );

	// this should match the fields in the template
	var rdata = [
            data.overdue[i].gid,
            data.overdue[i].cid,
            data.overdue[i].id,
            data.overdue[i].borrower_symbol,
            data.overdue[i].msg_to,
            data.overdue[i].title,
            data.overdue[i].author,
            data.overdue[i].ts,
            data.overdue[i].status,
            data.overdue[i].due_date,
            '<a href="mailto:'+data.overdue[i].email_address+'?subject=Overdue:+'+data.overdue[i].title+'&body=The+title+%22'+data.overdue[i].title+'%22,+borrowed+from+'+data.overdue[i].lending_library+',+was+due+on+'+data.overdue[i].due_date+'.%0D%0A%0D%0AIf+you+have+already+returned+this+title,+please+mark+it+as+%22Returned%22+in+fILL.%0D%0A%0D%0AThank+you">'+data.overdue[i].email_address+'</a>'
	];
	var rowNode = t.row.add( rdata ).draw().node();
	$(rowNode).attr("id",'req'+data.overdue[i].id);
	// the :eq selector looks at *visible* nodes....
	$(rowNode).children(":eq(0)").attr("title",data.overdue[i].library);
	if (data.overdue[i].opt_in == false) { // have not opted in for ILL
	    $(rowNode).children(":eq(0)").addClass("ill-status-no");
	    $(rowNode).children(":eq(0)").attr("title",data.overdue[i].library+" is not open for ILL");
	}
	//$(rowNode).children(":last").append( divResponses );

	lenderNotes_insertChild( t, rowNode,
				 data.overdue[i].lender_internal_note,
				 "datatable-detail"
			       );
    }

    lenderNotes_makeEditable();
}

