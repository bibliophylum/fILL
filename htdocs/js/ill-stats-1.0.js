// ill-stats.js
/*
    fILL - Free/Open-Source Interlibrary Loan management system
    Copyright (C) 2012  Government of Manitoba

    ill-stats.js is a part of fILL.

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

    var parms = { 
	oid: $("#oid").text()
    }
	
    $.getJSON('/cgi-bin/reports/ill-stats.cgi',
	      parms,
	      function(data){
	      })
	.success(function() {
	    $('#datatable_report').DataTable({
		"jQueryUI": true,
		"pagingType": "full_numbers",
		"info": true,
      		"ordering": true,
		"dom": '<"H"Tfr>t<"F"ip>',
		"pageLength": 12,
		"lengthMenu": [[12, 24, 48, -1], [12, 24, 48, "All"]],
		"tableTools": {
		    "sSwfPath": "/plugins/DataTables-1.10.2/extensions/TableTools/swf/copy_csv_xls_pdf.swf"
		},
		"order": [[0,"asc"],[1,"asc"]],
		"autoWidth": true,
		"scrollX": true, 
		"initComplete": function() {
		    // this handles a bug(?) in this version of datatables;
		    // hidden columns caused the table width to be set to 100px, not 100%
		    $("#datatable_report").css("width","100%");
		}
	    });
	})
	.error(function() {
	})
	.complete(function() {
	});


});


