// holds.js
/*
    fILL - Free/Open-Source Interlibrary Loan management system
    Copyright (C) 2012  Government of Manitoba

    holds.js is a part of fILL.

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

    $('#holds-table').DataTable({
        "jQueryUI": true,
        "pagingType": "full_numbers",
        "info": true,
        "ordering": true,
        "dom": '<"H"Bfr>t<"F"ip>',
	buttons: [ 'copy', 'excel', 'pdf', 'print' ],
        "columnDefs": [ {
            "targets": [0,1,2,7],
            "visible": false
        } ],
        "initComplete": function() {
            // this handles a bug(?) in this version of datatables;
            // hidden columns caused the table width to be set to 100px, not 100% 
            $("#holds-table").css("width","100%");
        }
	
    });

    $.getJSON('/cgi-bin/get-holds-list.cgi', {oid: $("#oid").text()},
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
        $( "#datepicker" ).datepicker({ dateFormat: 'yy-mm-dd' });
    });
    
    $(function() {
        update_menu_counters( $("#oid").text() );
    });

});

function build_table( data ) {
    var t = $('#holds-table').DataTable();
    
    for (var i=0;i<data.holds.length;i++) {

	var divResponses = create_action_buttons( data, i );

	// this should match the fields in the template
	var rdata = [
            data.holds[i].gid,
            data.holds[i].cid,
            data.holds[i].id,
            data.holds[i].title,
            data.holds[i].author,
            data.holds[i].patron_barcode,
            data.holds[i].ts,
            data.holds[i].msg_from,
            data.holds[i].from,
            data.holds[i].status,
            data.holds[i].message,
	    ""
	];
	var rowNode = t.row.add( rdata ).draw().node();
	$(rowNode).attr("id",'req'+data.holds[i].id);
	// the :eq selector looks at *visible* nodes....
	$(rowNode).children(":eq(5)").attr("title",data.holds[i].library);
	$(rowNode).children(":last").append( divResponses );

	// borrower internal note:
	var row = t.row(rowNode).child( 
	    'This is a child node that we will use for internal notes', "datatable-detail"
	).show();
    }
}

function create_action_buttons( data, i ) {
    var divResponses = document.createElement("div");
    var requestId = data.holds[i].id;
    divResponses.id = 'divResponses'+requestId;
    
    var b1 = document.createElement("input");
    b1.type = "button";
    b1.value = "Cancel request";
    b1.className = "action-button";
    b1.onclick = make_cancel_handler( requestId );
    divResponses.appendChild(b1);
    
    return divResponses;
}

// Explanation of why we need a function to create the buttons' onclick handlers:
// http://www.webdeveloper.com/forum/archive/index.php/t-100584.html
// Short answer: scoping and closures

function make_cancel_handler( requestId ) {
    return function() { cancel_request( requestId ) };
}

function cancel_request( requestId ) {
    var myRow=$("#req"+requestId);
    var nTr = myRow[0]; // convert jQuery object to DOM
    var oTable = $('#holds-table').dataTable();
    var aPos = oTable.fnGetPosition( nTr );
    var msg_to = oTable.fnGetData( aPos )[7]; // 8th column (0-based!), hidden or not

    var parms = {
	"reqid": requestId,
	"msg_to": msg_to,
	"oid": $("#oid").text(),
	"status": "Cancel",
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
