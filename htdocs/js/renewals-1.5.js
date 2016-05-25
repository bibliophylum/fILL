// renewals.js
/*
    fILL - Free/Open-Source Interlibrary Loan management system
    Copyright (C) 2012  Government of Manitoba

    renewals.js is a part of fILL.

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

    $('#renewals-table').DataTable({
        "jQueryUI": true,
        "pagingType": "full_numbers",
        "info": true,
        "ordering": true,
        "dom": '<"H"Bfr>t<"F"ip>',
	buttons: [ 'copy', 'excel', 'pdf', 'print' ],
        "columnDefs": [ {
            "targets": [0,1,2,8],
            "visible": false
        } ],
        "initComplete": function() {
            // this handles a bug(?) in this version of datatables;
            // hidden columns caused the table width to be set to 100px, not 100% 
            $("#renewals-table").css("width","100%");

	    $("#renewals-table").DataTable().page.len( parseInt($("#table_rows_per_page").text(),10));
        }
	
    });

    $.getJSON('/cgi-bin/get-renewals-list.cgi', {oid: $("#oid").text()},
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
    var t = $('#renewals-table').DataTable();
    
    for (var i=0;i<data.renewals.length;i++) {

	var divResponses = create_action_buttons( data, i );

	var libsym;
	var libname;
	var libid;
	if (data.renewals[i].status.search(/Renew-Answer/) != -1) {
            libsym = data.renewals[i].from;
	    libname = data.renewals[i].from_library;
            libid = data.renewals[i].msg_from;
	} else {
            libsym =  data.renewals[i].to;
	    libname = data.renewals[i].to_library;
            libid = data.renewals[i].msg_to;
	}

	// this should match the fields in the template
	var rdata = [
            data.renewals[i].gid,
            data.renewals[i].cid,
            data.renewals[i].id,
            data.renewals[i].title,
            data.renewals[i].author,
	    data.renewals[i].patron_barcode,
	    data.renewals[i].ts,
	    libsym,
	    libid,
	    data.renewals[i].status,
	    data.renewals[i].message,
	    ""
	];
	var rowNode = t.row.add( rdata ).draw().node();
	$(rowNode).attr("id",'req'+data.renewals[i].id);
	// the :eq selector looks at *visible* nodes....
	$(rowNode).children(":eq(4)").attr("title",libname);
	$(rowNode).children(":last").append( divResponses );

	// borrower internal note:
	var row = t.row(rowNode).child( 
	    'This is a child node that we will use for internal notes', "datatable-detail"
	).show();
    }
}

function create_action_buttons( data, i ) {
    var divResponses = document.createElement("div");
    var requestId = data.renewals[i].id;
    divResponses.id = 'divResponses'+requestId;
    
    if (data.renewals[i].status == 'Received') {
	var b1 = document.createElement("input");
	b1.type = "button";
	b1.value = "Ask for renewal";
	b1.className = "action-button";
	b1.onclick = make_renewals_handler( requestId );
	divResponses.appendChild(b1);
    } else if (data.renewals[i].status == 'Renew') {
	var b1 = document.createElement("input");
	b1.type = "button";
	b1.value = "Cancel renewal request";
	b1.className = "action-button";
	b1.onclick = make_cancel_handler( requestId );
	divResponses.appendChild(b1);
    }
    
    return divResponses;
}

// Explanation of why we need a function to create the buttons' onclick handlers:
// http://www.webdeveloper.com/forum/archive/index.php/t-100584.html
// Short answer: scoping and closures

function make_renewals_handler( requestId ) {
    return function() { request_renewal( requestId ) };
}

function request_renewal( requestId ) {
    var myRow=$("#req"+requestId);
    var nTr = myRow[0]; // convert jQuery object to DOM
    var oTable = $('#renewals-table').dataTable();
    var aPos = oTable.fnGetPosition( nTr );
    var msg_to = oTable.fnGetData( aPos )[8]; // 9th column (0-based!), hidden or not

    var parms = {
	"reqid": requestId,
	"msg_to": msg_to,
	"oid": $("#oid").text(),
	"status": "Renew",
	"message": ""
    };
    $.getJSON('/cgi-bin/change-request-status.cgi', parms,
	      function(data){
//		  alert('change request status: '+data+'\n'+parms[0].status);
	      })
	.success(function() {
	    // alert('success');
	    // change the text of the Status column, and highlight it.
	    var tbl = $('#renewals-table').DataTable(); // note the capitalized "DataTable"
	    var cell = tbl.cell( aPos, 9 );
	    cell.data('Renew');
	    var jQcell = cell.nodes();
	    $(jQcell).stop(true,true).effect("highlight", {}, 2000);
	    $("#divResponses"+requestId).empty();  // remove the button
	})
	.error(function() {
	    alert('error');
	})
	.complete(function() {
	    // slideUp doesn't work for <tr>
	    // Hmm... don't actually want the row removed, just updated.
	    //$("#req"+requestId).fadeOut(400, function() { $(this).remove(); }); // toast the row
	});
}


function make_cancel_handler( requestId ) {
    return function() { cancel_renewal( requestId ) };
}

function cancel_renewal( requestId ) {
    var myRow=$("#req"+requestId);
    var nTr = myRow[0]; // convert jQuery object to DOM
    var oTable = $('#renewals-table').dataTable();
    var aPos = oTable.fnGetPosition( nTr );
    var msg_to = oTable.fnGetData( aPos )[8]; // 9th column (0-based!), hidden or not

    var parms = {
	"reqid": requestId,
	"msg_to": msg_to,
	"oid": $("#oid").text(),
	"status": "Cancel-Renewal-Request",
	"message": ""
    };
    $.getJSON('/cgi-bin/cancel-renewal-request.cgi', parms,
	      function(data){
//		  alert('change request status: '+data+'\n'+parms[0].status);
	      })
	.success(function() {
	    // alert('success');
	    // change the text of the Status column, and highlight it.
	    var tbl = $('#renewals-table').DataTable(); // note the capitalized "DataTable"
	    var cell = tbl.cell( aPos, 9 );
	    cell.data('Received');
	    var jQcell = cell.nodes();
	    $(jQcell).stop(true,true).effect("highlight", {}, 2000);
	    $("#divResponses"+requestId).empty();  // remove the button
	})
	.error(function() {
	    alert('error');
	})
	.complete(function() {
	    // slideUp doesn't work for <tr>
	    // Hmm... don't actually want the row removed, just updated.
	    //$("#req"+requestId).fadeOut(400, function() { $(this).remove(); }); // toast the row
	});
}
