// lost.js
/*
    fILL - Free/Open-Source Interlibrary Loan management system
    Copyright (C) 2012  Government of Manitoba

    lost.js is a part of fILL.

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

    $('#lost-table').DataTable({
        "jQueryUI": true,
        "pagingType": "full_numbers",
        "info": true,
        "ordering": true,
        "dom": '<"H"Bfr>t<"F"ip>',
	buttons: [ 'copy', 'excel', 'pdf', 'print' ],
        "columnDefs": [ {
            "targets": [0,1,2],
            "visible": false
        } ],
        "initComplete": function() {
            // this handles a bug(?) in this version of datatables;
            // hidden columns caused the table width to be set to 100px, not 100%
            $("#lost-table").css("width","100%");
        }
    });

    $.getJSON('/cgi-bin/get-lost-list.cgi', {oid: $("#oid").text()},
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
    var t = $('#lost-table').DataTable();
    
    for (var i=0;i<data.lostlist.length;i++) {

	var divResponses = create_action_buttons( data, i );

	// this should match the fields in the template
	var rdata = [
            data.lostlist[i].gid,
            data.lostlist[i].cid,
            data.lostlist[i].id,
            data.lostlist[i].title,
            data.lostlist[i].author,
            data.lostlist[i].ts,
            data.lostlist[i].from,
            data.lostlist[i].phone,
            data.lostlist[i].library+'<br />'+data.lostlist[i].mailing_address_line1+'<br />'+data.lostlist[i].mailing_address_line2+'<br />'+data.lostlist[i].mailing_address_line3+'<br />'+data.lostlist[i].city+', '+data.lostlist[i].province+'  '+data.lostlist[i].postcode,
            data.lostlist[i].status,
            data.lostlist[i].message,
	    ""
	];
	var rowNode = t.row.add( rdata ).draw().node();
	$(rowNode).attr("id",'req'+data.lostlist[i].id);
	// the :eq selector looks at *visible* nodes....
	$(rowNode).children(":eq(3)").attr("title",data.lostlist[i].library);
	$(rowNode).children(":last").append( divResponses );

	// lender internal note:
	var row = t.row(rowNode).child( 
	    'This is a child node that we will use for internal notes', "datatable-detail"
	).show();
    }
}

function create_action_buttons( data, i ) {
    var divResponses = document.createElement("div");
    var requestId = data.lostlist[i].id;
    divResponses.id = 'divResponses'+requestId;
    
    var b1 = document.createElement("input");
    b1.type = "button";
    b1.value = "Move to history";
    b1.className = "action-button";
    b1.onclick = make_movetohistory_handler( requestId );
    divResponses.appendChild(b1);
    
    return divResponses;
}

// Explanation of why we need a function to create the buttons' onclick handlers:
// http://www.webdeveloper.com/forum/archive/index.php/t-100584.html
// Short answer: scoping and closures

function make_movetohistory_handler( requestId ) {
    return function() { move_to_history( requestId ) };
}

function move_to_history( requestId ) {
    var myRow=$("#req"+requestId);
    var parms = {
	reqid: requestId,
	msg_to: $("#oid").text(),  // message to myself
	oid: $("#oid").text(),
	status: "Message",
	message: "Lender closed the request (borrower lost item)."
    }
    $.getJSON('/cgi-bin/change-request-status.cgi', parms,
	      function(data){
//		  alert('change request status: '+data+'\n'+parms[0].status);
	      })
	.success(function() {
	    //alert('success');
	    $.getJSON('/cgi-bin/move-to-history.cgi', { 'reqid' : requestId },
		      function(data){
			  //alert('Moved to history? '+data.success+'\n  Closed? '+data.closed+'\n  History? '+data.history+'\n  Active? '+data.active+'\n  Sources? '+data.sources+'\n  Request? '+data.request);
		      });
	})
	.error(function() {
	    alert('error');
	})
	.complete(function() {
	    // slideUp doesn't work for <tr>
	    $("#req"+requestId).fadeOut(400, function() { $(this).remove(); }); // toast the row
	});
}
