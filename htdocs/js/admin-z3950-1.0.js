// admin-z3950.js
/*
    fILL - Free/Open-Source Interlibrary Loan management system
    Copyright (C) 2012  Government of Manitoba

    admin-z3950 is a part of fILL.

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

    // Most primary tabs are set as the current tab in the submenu_xxxxx.
    // welcome menu doesn't have a submenu, so we set the current tab here.
    //
    //set_primary_tab("menu_zserver");
    set_secondary_tab("menu_zserver_settings");

    $("#formSubmit").on('click', function(e){
	e.preventDefault();
	//alert("Submit clicked.");
	var parms = {
	    "oid": $("#editOID").val(),
	    "server": $("#server").val(),
	    "port": $("#port").val(),
	    "database": $("#database").val(),
	    "request_syntax": $("#request_syntax").val(),
	    "elements": $("#elements").val(),
	    "nativesyntax": $("#nativesyntax").val(),
	    "xslt": $("#xslt").val(),
	    "index_keyword": $("#index_keyword").val(),
	    "index_author": $("#index_author").val(),
	    "index_title": $("#index_title").val(),
	    "index_subject": $("#index_subject").val(),
	    "index_isbn": $("#index_isbn").val(),
	    "index_issn": $("#index_issn").val(),
	    "index_date": $("#index_date").val(),
	    "index_series": $("#index_series").val(),
	    "enabled": $('input[name=enabled]:checked', '#editForm').val()
	};
	$.getJSON('/cgi-bin/admin-update-z3950settings.cgi', parms,
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
	$("#editOID").val( $('td:eq(0)', this).text() );
	// symbol is td:eq(1), but we don't use it
	$("#library").text( $('td:eq(2)', this).text() );
	var isEnabled = $('td:eq(3)').text();
	$('input:radio[name="enabled"][value="'+isEnabled+'"]').prop('checked', true);
	$("#server").val( $('td:eq(4)', this).text() );
	$("#port").val( $('td:eq(5)', this).text() );
	$("#database").val( $('td:eq(6)', this).text() );
	$("#request_syntax").val( $('td:eq(7)', this).text() );
	$("#elements").val( $('td:eq(8)', this).text() );
	$("#nativesyntax").val( $('td:eq(9)', this).text() );
	$("#xslt").val( $('td:eq(10)', this).text() );
	$("#index_keyword").val( $('td:eq(11)', this).text() );
	$("#index_author").val( $('td:eq(12)', this).text() );
	$("#index_title").val( $('td:eq(13)', this).text() );
	$("#index_subject").val( $('td:eq(14)', this).text() );
	$("#index_isbn").val( $('td:eq(15)', this).text() );
	$("#index_issn").val( $('td:eq(16)', this).text() );
	$("#index_date").val( $('td:eq(17)', this).text() );
	$("#index_series").val( $('td:eq(18)', this).text() );
	$("#edit").show();
	window.location.hash = '#edit';  // jump to the div
	$("#myDiv").hide();
    } );

    var table = $("#libraries").DataTable({
        "jQueryUI": true,
        "pagingType": "full_numbers",
        "info": true,
        "ordering": true,
        "dom": '<"H"lfrT>t<"F"ip>',
        "pageLength": 10,
        "lengthMenu": [[10, 25, 50, -1], [10, 25, 50, "All"]],
	"ajax": "/cgi-bin/admin-get-z3950settings.cgi",
	"columns": [    
	    { "data": "oid" },    
	    { "data": "name" },    
	    { "data": "library" },    
	    { "data": "enabled" },
	    { "data": "server_address" },    
	    { "data": "server_port" },  
	    { "data": "database_name" },
	    { "data": "request_syntax" },
	    { "data": "elements" },
	    { "data": "nativesyntax" },
	    { "data": "xslt" },
	    { "data": "index_keyword" },
	    { "data": "index_author" },
	    { "data": "index_title" },
	    { "data": "index_subject" },
	    { "data": "index_isbn" },
	    { "data": "index_issn" },
	    { "data": "index_date" },
	    { "data": "index_series" }
	],	
	"tableTools": {
          "sSwfPath": "/plugins/DataTables-1.10.2/extensions/TableTools/swf/copy_csv_xls_pdf.swf"
	},
	"autoWidth": true,
//	"scrollX": true,  // this is now done by wrapping the table in a scrollStyle class div.  Using table.ajax.reload() to re-get the data had the header widths out of sync with the column widths when using scrollX.
        "initComplete": function() {
            // this handles a bug(?) in this version of datatables;
            // hidden columns caused the table width to be set to 100px, not 100%
            $("#libraries").css("width","100%");

	    $("#libraries").wrap('<div class="scrollStyle" />'); 
	    $("#mylistDiv").show();
        }
    });
    

});
