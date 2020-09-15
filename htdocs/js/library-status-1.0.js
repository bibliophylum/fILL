// library-status.js
/*
    fILL - Free/Open-Source Interlibrary Loan management system
    Copyright (C) 2012  Government of Manitoba

    library-status.js is a part of fILL.

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

    $('#library-status-list').DataTable({
        "jQueryUI": true,
        "pagingType": "full_numbers",
        "info": true,
        "ordering": true,
        "dom": '<"H"Bfr>t<"F"ip>',
	buttons: [ 'copy', 'excel', 'pdf', 'print' ],
        "columnDefs": [ {
            "targets": [0],
            "visible": false
        } ],
        "initComplete": function() {
            // this handles a bug(?) in this version of datatables;
            // hidden columns caused the table width to be set to 100px, not 100%
            $("#library-status-list").css("width","100%");

	    $("#library-status-list").DataTable().page.len( parseInt($("#table_rows_per_page").text(),10));
        }
    });

  $.getJSON('/cgi-bin/get-library-status-list.cgi', 
	    function(data){
		build_table(data); 
		$("#waitDiv-libstatuses").hide();
		$("#mylistDiv").show();
            })
	.success(function() {
        })
	.error(function() {
        })
	.complete(function() {
	    alert('Again, number of rows: '+$("#library-status-list").DataTable().column(0).data().length);
	});
    
});

function build_table( data ) {
    var t = $('#library-status-list').DataTable();
    
    for (var i=0;i<data.libstatuses.length;i++) {
	console.log("status data: "+data.libstatuses[i].symbol+", "+data.libstatuses[i].status);

	// this should match the fields in the template
	var rdata = [
            data.libstatuses[i].oid,
            data.libstatuses[i].symbol,
            data.libstatuses[i].library,
            data.libstatuses[i].status
	];
	var rowNode = t.row.add( rdata ).draw().node();
	$(rowNode).attr("id",'lib'+data.libstatuses[i].oid);
    }
    alert('Number of rows: '+t.column(0).data().length);
}

