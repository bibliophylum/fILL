// checkins.js
/*
    fILL - Free/Open-Source Interlibrary Loan management system
    Copyright (C) 2012  Government of Manitoba

    checkins.js is a part of fILL.

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

    $('#checkins-table').DataTable({
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
            $("#checkins-table").css("width","100%");
        }
    });
    
    $.getJSON('/cgi-bin/get-checkin-list.cgi', {oid: $("#oid").text()},
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
    var t = $('#checkins-table').DataTable();
    
    for (var i=0;i<data.checkins.length;i++) {

	var divResponses = create_action_buttons( data, i );

	// this should match the fields in the template
	var rdata = [
            data.checkins[i].gid,
            data.checkins[i].cid,
            data.checkins[i].id,
            data.checkins[i].title,
            data.checkins[i].author,
            data.checkins[i].ts,
            data.checkins[i].from,
            data.checkins[i].msg_from,
	    ""
	];
	var rowNode = t.row.add( rdata ).draw().node();
	$(rowNode).attr("id",'req'+data.checkins[i].id);
	// the :eq selector looks at *visible* nodes....
	$(rowNode).children(":eq(3)").attr("title",data.checkins[i].library);
	$(rowNode).children(":last").append( divResponses );

	lenderNotes_insertChild( t, rowNode,
				 data.checkins[i].lender_internal_note,
				 "datatable-detail"
			       );
    }

    lenderNotes_makeEditable();
}

function create_action_buttons( data, i ) {
    var divResponses = document.createElement("div");
    var requestId = data.checkins[i].id;
    divResponses.id = 'divResponses'+requestId;
    
    var b1 = document.createElement("input");
    b1.type = "button";
    b1.value = "Checked in to ILS";
    b1.className = "action-button";
    b1.onclick = make_checkin_handler( requestId );
    divResponses.appendChild(b1);
    
    if (data.checkins[i].tracking) {
	var $tracking = $('<input/>', 
			  {
			      'type':'button', 
			      'value':'CP tracking', 
			      'class':'action-button',
			      'click': make_tracking_handler( data.checkins[i].tracking )
			  });
	divResponses.appendChild( $tracking[0] );
    }
    return divResponses;
}

// Explanation of why we need a function to create the buttons' onclick handlers:
// http://www.webdeveloper.com/forum/archive/index.php/t-100584.html
// Short answer: scoping and closures

function make_checkin_handler( requestId ) {
    return function() { checkin( requestId ) };
}

function checkin( requestId ) {
    var myRow=$("#req"+requestId);
    var nTr = myRow[0]; // convert jQuery object to DOM
    var oTable = $('#checkins-table').dataTable();
    var aPos = oTable.fnGetPosition( nTr );
    var msg_to = oTable.fnGetData( aPos )[7]; // 8th column (0-based!), hidden or not

    var parms = {
	reqid: requestId,
	msg_to: msg_to,  // sending TO whoever original was FROM
	oid: $("#oid").text(),
	status: "Checked-in",
	message: ""
    }
    $.getJSON('/cgi-bin/change-request-status.cgi', parms,
	      function(data){
//		  alert('change request status: '+data+'\n'+parms[0].status);
	      })
	.success(function() {
	    //alert('success');
	    $.getJSON('/cgi-bin/move-to-history.cgi', { 'reqid' : requestId },
		      function(data){
//			  alert('Moved to history? '+data.success+'\n  Closed? '+data.closed+'\n  History? '+data.history+'\n  Active? '+data.active+'\n  Sources? '+data.sources+'\n  Request? '+data.request);
		      });
	})
	.error(function() {
	    alert('error');
	})
	.complete(function() {
	    // toast any child nodes (eg lender internal notes)
	    var t = $("#checkins-table").DataTable();
	    t.row("#req"+requestId).child.remove();
	    // slideUp doesn't work for <tr>
	    $("#req"+requestId).fadeOut(400, function() { $(this).remove(); }); // toast the row
	});
}

function make_tracking_handler( tracking ) {
    return function() { window.open("http://www.canadapost.ca/cpotools/apps/track/personal/findByTrackNumber?trackingNumber="+tracking, "_blank"); };
}
