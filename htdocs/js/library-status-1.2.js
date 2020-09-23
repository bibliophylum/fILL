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

$('document').ready(function() {

    var table = $("#library-status-list").DataTable({
        "jQueryUI": true,
        "pagingType": "full_numbers",
        "info": true,
        "ordering": true,
        "dom": '<"H"lfrT>t<"F"ip>',
        "pageLength": 50,
        "lengthMenu": [[10, 25, 50, -1], [10, 25, 50, "All"]],
	"autoWidth": false,
	"ajax": {"url":"/cgi-bin/get-library-status-list.cgi", "dataSrc": "libstatuses"},
	"columns": [    
	    { "data": "oid", "visible": false },    
	    { "data": "symbol", "width": "15%" },    
	    { "data": "library", "width": "25%" },    
	    { "data": "lib_status" }
	],	
	"tableTools": {
          "sSwfPath": "/plugins/DataTables-1.10.2/extensions/TableTools/swf/copy_csv_xls_pdf.swf"
	},
	"autoWidth": true,
//	"scrollX": true,  // this is now done by wrapping the table in a scrollStyle class div.  Using table.ajax.reload() to re-get the data had the header widths out of sync with the column widths when using scrollX.
        "initComplete": function() {
            // this handles a bug(?) in this version of datatables;
            // hidden columns caused the table width to be set to 100px, not 100%
            $("#library-status-list").css("width","100%");

	    $("#library-status-list").wrap('<div class="scrollStyle" />');
	    $("#waitDiv-libstatuses").hide();
	    $("#mylistDiv").show();
        }
    });
    

});
