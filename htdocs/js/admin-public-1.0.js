// admin-public.js
/*
    fILL - Free/Open-Source Interlibrary Loan management system
    Copyright (C) 2012  Government of Manitoba

    admin-public is a part of fILL.

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

$('document').ready(function() {

    set_secondary_tab("menu_public_featured");

    $("#formSubmit").on('click', function(e){
	e.preventDefault();
	//alert("Submit clicked.");
	var parms = {
	    "isbn": $("#isbn").val(),
	    "title": $("#title").val(),
	    "author": $("#author").val()
	};
	$.getJSON('/cgi-bin/admin-public-featured-add.cgi', parms,
		  function(data){
		  })
	    .success(function() {
		table.ajax.reload();
	    })
	    .error(function(data) {
		alert('error');
	    })
	    .complete(function() {
	    });
	$("#edit").hide();
	$("#myDiv").show();
	window.location.hash = '#myDiv';
    });

    $('#libraries tbody').on('click', 'tr', function () {
	$("#editFID").val( $('td:eq(0)', this).text() );
	$("#isbn").text( $('td:eq(1)', this).text() );
	$("#title").val( $('td:eq(2)', this).text() );
	$("#author").val( $('td:eq(3)', this).text() );
	//$("#edit").show();
	window.location.hash = '#edit';  // jump to the div
	//$("#myDiv").hide();
    } );

    var table = $("#featured").DataTable({
        "jQueryUI": true,
        "pagingType": "full_numbers",
        "info": true,
        "ordering": true,
        "dom": '<"H"lfrT>t<"F"ip>',
        "pageLength": 10,
        "lengthMenu": [[10, 25, 50, -1], [10, 25, 50, "All"]],
	"ajax": "/cgi-bin/admin-get-publicfeatured.cgi",
	"columns": [    
	    { "data": "fid" },    
	    { "data": "isbn" },    
	    { "data": "title" },    
	    { "data": "author" },
	    { "data": "cover" },    
	    { "data": "added" }
	],	
	"tableTools": {
          "sSwfPath": "/plugins/DataTables-1.10.2/extensions/TableTools/swf/copy_csv_xls_pdf.swf"
	},
	"autoWidth": true,
        "initComplete": function() {
            // this handles a bug(?) in this version of datatables;
            // hidden columns caused the table width to be set to 100px, not 100%
            $("#featured").css("width","100%");
	    $("#mylistDiv").show();
        }
    });
    

});
