// on_hold.js
/*
    fILL - Free/Open-Source Interlibrary Loan management system
    Copyright (C) 2012  Government of Manitoba

    on_hold.js is a part of fILL.

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

    $('#on-hold-table').DataTable({
        "jQueryUI": true,
        "pagingType": "full_numbers",
        "info": true,
        "ordering": true,
        "dom": '<"H"Bfr>t<"F"ip>',
	buttons: [ 'copy', 'excel', 'pdf', 'print' ],
        "columnDefs": [ {
            "targets": [0,1,2,4],
            "visible": false
        } ],
        "initComplete": function() {
            // this handles a bug(?) in this version of datatables;
            // hidden columns caused the table width to be set to 100px, not 100%
            $("#on-hold-table").css("width","100%");
        }
    });
    
    $.getJSON('/cgi-bin/get-on-hold.cgi', {oid: $("#oid").text()},
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
    var t = $('#on-hold-table').DataTable();

    for (var i=0;i<data.on_hold.length;i++) {

	var divResponses = create_action_buttons( data, i );

	// this should match the fields in the template
	var rdata = [
            data.on_hold[i].gid,
            data.on_hold[i].cid,
            data.on_hold[i].id,
            data.on_hold[i].from,
            data.on_hold[i].msg_to,
            data.on_hold[i].author,
            data.on_hold[i].title,
            data.on_hold[i].ts,
            data.on_hold[i].date_expected,
	    ""
	];

	var rowNode = t.row.add( rdata ).draw().node();
	$(rowNode).attr("id",'req'+data.on_hold[i].id);
	// the :eq selector looks at *visible* nodes....
	$(rowNode).children(":eq(0)").attr("title",data.on_hold[i].library);
	$(rowNode).children(":last").append( divResponses );

	// lender internal note:
	var row = t.row(rowNode).child( 
	    'This is a child node that we will use for internal notes', "datatable-detail"
	).show();
    }
}

function create_action_buttons( data, i ) {
    var divResponses = document.createElement("div");
    var requestId = data.on_hold[i].id;
    divResponses.id = 'divResponses'+requestId;
    
    var b1 = document.createElement("input");
    b1.type = "button";
    if (data.on_hold[i].cancel == 1) {
	b1.value = "Cancelled by borrower";
	b1.className = "action-button-highlighted";
	b1.onclick = make_cancelled_handler( requestId );
    } else {
	b1.value = "Ready to ship";
	b1.className = "action-button";
	b1.onclick = make_shipper_handler( requestId );
    }
    divResponses.appendChild(b1);
    
    if (data.on_hold[i].cancel != 1) {
	var b2 = document.createElement("input");
	b2.type = "button";
	b2.value = "Un-hold (return to Respond)";
	b2.className = "action-button";
	b2.onclick = make_unhold_handler( requestId );
	divResponses.appendChild(b2);
    }
    
    return divResponses;
}


// Explanation of why we need a function to create the buttons' onclick handlers:
// http://www.webdeveloper.com/forum/archive/index.php/t-100584.html
// Short answer: scoping and closures

function make_shipper_handler( requestId ) {
    return function() { shipper( requestId ) };
}

function shipper( requestId ) {
    var myRow=$("#req"+requestId);
    var nTr = myRow[0]; // convert jQuery object to DOM
    var oTable = $('#on-hold-table').dataTable();
    var aPos = oTable.fnGetPosition( nTr );
    var msg_to = oTable.fnGetData( aPos )[4]; // 5th column (0-based!), hidden or not

    var parms = {
	"reqid": requestId,
	"msg_to": msg_to,
	"oid": $("#oid").text(),
	"status": "ILL-Answer|Will-Supply|being-processed-for-supply",
	"message": ""
    };
    $.getJSON('/cgi-bin/change-request-status.cgi', parms,
	      function(data){
//		  alert('change request status: '+data+'\n'+parms[0].status);
	      })
	.success(function() {
	    update_menu_counters( $("#oid").text() );
	})
	.error(function() {
	    alert('error');
	})
	.complete(function() {
	    // slideUp doesn't work for <tr>
	    $("#req"+requestId).fadeOut(400, function() { $(this).remove(); }); // toast the row
	});
}

function make_cancelled_handler( requestId ) {
    return function() { cancelled( requestId ) };
}

function cancelled( requestId ) {
    var myRow=$("#req"+requestId);
    var nTr = myRow[0]; // convert jQuery object to DOM
    var oTable = $('#on-hold-table').dataTable();
    var aPos = oTable.fnGetPosition( nTr );
    var msg_to = oTable.fnGetData( aPos )[4]; // 5th column (0-based!), hidden or not

    var parms = {
	"reqid": requestId,
	"msg_to": msg_to,
	"oid": $("#oid").text(),
	"status": "Cancel-Reply",
	"message": "Ok"
    };
    $.getJSON('/cgi-bin/change-request-status.cgi', parms,
	      function(data){
//		  alert('change request status: '+data+'\n'+parms[0].status);
	      })
	.success(function() {
	    $.getJSON('/cgi-bin/move-to-history.cgi', { 'reqid' : requestId },
		      function(data){
			  //alert('Moved to history? '+data.success+'\n  Closed? '+data.closed+'\n  History? '+data.history+'\n  Active? '+data.active+'\n  Sources? '+data.sources+'\n  Request? '+data.request);
		      });
	})
	.error(function() {
	    alert('error');
	})
	.complete(function() {
	    update_menu_counters( $("#oid").text() );
	    // slideUp doesn't work for <tr>
	    $("#req"+requestId).fadeOut(400, function() { $(this).remove(); }); // toast the row
	});
}


function make_unhold_handler( requestId ) {
    return function() { unhold( requestId ) };
}

function unhold( requestId ) {
    var myRow=$("#req"+requestId);
    var nTr = myRow[0]; // convert jQuery object to DOM
    var oTable = $('#on-hold-table').dataTable();
    var aPos = oTable.fnGetPosition( nTr );
    var msg_to = oTable.fnGetData( aPos )[4]; // 5th column (0-based!), hidden or not

    var parms = {
	"reqid": requestId,
	"msg_to": msg_to,
	"oid": $("#oid").text()
    };
    $.getJSON('/cgi-bin/cancel-hold.cgi', parms,
	      function(data){
//		  alert('change request status: '+data+'\n'+parms[0].status);
	      })
	.success(function() {
	    update_menu_counters( $("#oid").text() );
	})
	.error(function() {
	    alert('error');
	})
	.complete(function() {
	    // slideUp doesn't work for <tr>
	    $("#req"+requestId).fadeOut(400, function() { $(this).remove(); }); // toast the row
	});
}

