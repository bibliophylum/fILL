// rotation-admin.js
/*
    fILL - Free/Open-Source Interlibrary Loan management system
    Copyright (C) 2012  Government of Manitoba

    rotation-admin.js is a part of fILL.

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

    $("#fileupload")
	.bind("fileuploadadd", function (e, data) {
	    $.each(data.files, function (index, file) {
		console.log('Added file: ' + file.name);
	    });
	    var jqXHR = data.submit()
		.success(function (result, textStatus, jqXHR) {/* ... */})
		.error(function (jqXHR, textStatus, errorThrown) {/* ... */})
		.complete(function (result, textStatus, jqXHR) {
		    $.each(data.files, function (index, file) {
			var $f = $('<p/>').text(file.name).appendTo('#files');
			$f.stop(true,true).effect("highlight", {}, 2000);
			// $("#files").append('<p/>').text(file.name).stop(true,true).effect("highlight", {}, 2000);
		    });
		});
	})
	.bind("fileuploaddone", function (e, data) {
	    $.each(data.result.files, function (index, file) {
		$('<p/>').text(file.name).appendTo('#files');
	    });
	})
	.bind("fileuploadprogressall", function (e, data) {
	    var progress = parseInt(data.loaded / data.total * 100, 10);
	    $('#progress .progress-bar').css(
		'width',
		progress + '%'
	    );
	});
    
    /*jslint unparam: true */
    /*global window, $ */
    $(function () {
	'use strict';
	$('#fileupload').fileupload({
	    url: '/cgi-bin/rotations-admin-upload-handler.cgi',
	    dataType: 'json',
	}).prop('disabled', !$.support.fileInput)
            .parent().addClass($.support.fileInput ? undefined : 'disabled');
    });
    
    $("#processButton").on("click",function(data){
        $.getJSON('/cgi-bin/rotations-admin-process-uploads.cgi', 
		  function(data){
		      $.each( data, function( fileset, fsdata ){
			  var slines = [];
			  slines.push("<li>File: "+fsdata.basename+"</li>");
			  slines.push("<li>Records in file: "+fsdata.records_in_file+"</li>");
			  slines.push("<li>Records processed: "+fsdata.records_processed_for_loading+"</li>");
			  slines.push("<li>Records loaded: "+fsdata.records_loaded+"</li>");
			  $( "<ul/>", {
			      "class": "my-new-list",
			      html: slines.join( "" )
			  }).appendTo( "#processStats" );

			  build_process_report_table( fileset, fsdata );
			  build_load_report_table( fileset, fsdata );
			  
		      });
		  })
            .done(function() {
		//alert('success');
	    })
	    .fail(function() {
		alert('error');
	    })
	    .always(function() {
		//alert('ajax complete');
	    });  // end of .complete()
	
    });
    
});


function build_process_report_table( fileset, fsdata ) {
    var myTable = document.createElement("table");
    myTable.setAttribute("id","process-report-table-"+fileset);
    myTable.className = myTable.className + " row-border";
    var tHead = myTable.createTHead();
    var row = tHead.insertRow(-1);
    var cell;
    // Can't just use:
    // cell = row.insertCell(-1); cell.innerHTML = "ID";
    // ...because insertCell inserts TD elements, and our CSS uses TH for header cells.
    
    cell = document.createElement("TH"); cell.innerHTML = "author"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "callno"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "barcode"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "title"; row.appendChild(cell);
    
    var tFoot = myTable.createTFoot();
    row = tFoot.insertRow(-1);
    cell = row.insertCell(-1); cell.colSpan = "4"; cell.innerHTML = "";
    
    // explicit creation of TBODY element to make IE happy
    var tBody = document.createElement("TBODY");
    myTable.appendChild(tBody);
    
    $.each( fsdata.process_report, function( r, pdata ) {
        row = tBody.insertRow(-1); row.id = 'procrep'+pdata.r;
        cell = row.insertCell(-1); cell.innerHTML = pdata.author;
        cell = row.insertCell(-1); cell.innerHTML = pdata.callno;
        cell = row.insertCell(-1); cell.innerHTML = pdata.barcode;
        cell = row.insertCell(-1); cell.innerHTML = pdata.title;
    });
    
    document.getElementById('processReport').appendChild(myTable);
    $("#process-report-table-"+fileset).dataTable({
         "bJQueryUI": true,
         "sPaginationType": "full_numbers",
         "bInfo": true,
         "bSort": true,
         "sDom": '<"H"Tfr>t<"F"ip>',
         "iDisplayLength": 120,
         "bLengthChange": true,
         "oTableTools": {
           "sSwfPath": "/plugins/DataTables-1.10.2/extensions/TableTools/swf/copy_csv_xls_pdf.swf"
         },
    });
}

function build_load_report_table( fileset, fsdata ) {
    var myTable = document.createElement("table");
    myTable.setAttribute("id","load-report-table-"+fileset);
    myTable.className = myTable.className + " row-border";
    var tHead = myTable.createTHead();
    var row = tHead.insertRow(-1);
    var cell;

    // Can't just use:
    // cell = row.insertCell(-1); cell.innerHTML = "ID";
    // ...because insertCell inserts TD elements, and our CSS uses TH for header cells.
    
    cell = document.createElement("TH"); cell.innerHTML = "title"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "author"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "callno"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "barcode"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "status"; row.appendChild(cell);
    
    var tFoot = myTable.createTFoot();
    row = tFoot.insertRow(-1);
    cell = row.insertCell(-1); cell.colSpan = "5"; cell.innerHTML = "";
    
    // explicit creation of TBODY element to make IE happy
    var tBody = document.createElement("TBODY");
    myTable.appendChild(tBody);
    
    $.each( fsdata.load_report, function( r, ldata ) {
        row = tBody.insertRow(-1); row.id = 'loadrep'+r;
        cell = row.insertCell(-1); cell.innerHTML = ldata.title;
        cell = row.insertCell(-1); cell.innerHTML = ldata.author;
        cell = row.insertCell(-1); cell.innerHTML = ldata.callno;
        cell = row.insertCell(-1); cell.innerHTML = ldata.barcode;
        cell = row.insertCell(-1); cell.innerHTML = ldata.status;
    });
    
    document.getElementById('loadReport').appendChild(myTable);
    $("#load-report-table-"+fileset).dataTable({
         "bJQueryUI": true,
         "sPaginationType": "full_numbers",
         "bInfo": true,
         "bSort": true,
         "sDom": '<"H"Tfr>t<"F"ip>',
         "iDisplayLength": 120,
         "bLengthChange": true,
         "oTableTools": {
           "sSwfPath": "/plugins/DataTables-1.10.2/extensions/TableTools/swf/copy_csv_xls_pdf.swf"
         },
    });
}
