// pending.js
/*
    fILL - Free/Open-Source Interlibrary Loan management system
    Copyright (C) 2012  Government of Manitoba

    pending.js is a part of fILL.

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

    $('#pending-table').DataTable({
        "jQueryUI": true,
        "pagingType": "full_numbers",
        "info": true,
        "ordering": true,
        "dom": '<"H"Bfr>t<"F"ip>',
	buttons: [ 'copy', 'excel', 'pdf', 'print' ],
        "columnDefs": [ {
            "targets": [0,1,2,9],
            "visible": false
        } ],
        "initComplete": function() {
            // this handles a bug(?) in this version of datatables;
            // hidden columns caused the table width to be set to 100px, not 100%
            $("#pending-table").css("width","100%");
        }
    });

  $.getJSON('/cgi-bin/get-pending-list.cgi', {oid: $("#oid").text()},
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
    var t = $('#pending-table').DataTable();
    
    for (var i=0;i<data.noresponse.length;i++) {

	var divResponses = create_action_buttons( data, i );

	// this should match the fields in the template
	var rdata = [
            data.noresponse[i].gid,
            data.noresponse[i].cid,
            data.noresponse[i].id,
            data.noresponse[i].title,
            data.noresponse[i].author,
            data.noresponse[i].patron_barcode,
            data.noresponse[i].ts,
            data.noresponse[i].age,
            data.noresponse[i].to,
            data.noresponse[i].status,
            data.noresponse[i].tried+' of '+data.noresponse[i].sources,
	    ""
	];
	var rowNode = t.row.add( rdata ).draw().node();
	$(rowNode).attr("id",'req'+data.noresponse[i].id);
	// the :eq selector looks at *visible* nodes....
	$(rowNode).children(":eq(5)").attr("title",data.noresponse[i].library);
	$(rowNode).children(":last").append( divResponses );

	// borrower internal note:
	var row = t.row(rowNode).child( 
	    'This is a child node that we will use for internal notes', "datatable-detail"
	).show();
    }
}

function create_action_buttons( data, i ) {
    var divResponses = document.createElement("div");
    var requestId = data.noresponse[i].id;
    divResponses.id = 'divResponses'+data.noresponse[i].id;
    
    var b1 = document.createElement("input");
    b1.type = "button";
    b1.value = "Try next lender";
    b1.className = "action-button";
    if (+data.noresponse[i].tried >= +data.noresponse[i].sources) {
	b1.value = "No other lenders";
	b1.disabled = "disabled";
    }
    if (+data.noresponse[i].age < 3) {
	// if the request was made less than 3 days ago, disable the
	// try-next-lender button. Note that this only affects the *first*
	// source in the (sorted) sources list; after this, the request will
	// be in the "unfilled" list instead of this "pending" list.
	b1.value = "Waiting "+(3 - +data.noresponse[i].age)+( 3 - +data.noresponse[i].age == 1 ? " day" : " days");
	b1.disabled = "disabled";
    }
    var chainId = data.noresponse[i].cid;
    b1.onclick = make_trynextlender_handler( requestId, chainId );
    divResponses.appendChild(b1);
    
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

function make_trynextlender_handler( requestId, chainId ) {
    return function() { try_next_lender( requestId, chainId ) };
}

function try_next_lender( requestId, chainId ) {
    var myRow=$("#req"+requestId);
    var parms = {
	reqid: requestId,
	oid: $("#oid").text(),
    }
    $.getJSON('/cgi-bin/try-next-lender.cgi', parms,

// Use override.cgi instead of try-next-lender.cgi - we want the override msg
// No... bTryNextLender is no longer a valid override. -DC 2015-12-10
//    var parms = {
//	cid: chainId,
//	override: 'bTryNextLender',
//    }
//    $.getJSON('/cgi-bin/override.cgi', parms,
	      function(data){
		  if (data.alert_text) { alert(data.alert_text); };
	      })
	.success(function() {
	    //alert('success');
	})
	.error(function() {
	    alert('error');
	})
	.complete(function() {
	    // slideUp doesn't work for <tr>
	    $("#req"+requestId).fadeOut(400, function() { $(this).remove(); }); // toast the row
	});
}

function make_cancel_handler( requestId ) {
    return function() { cancel( requestId ) };
}

function cancel( requestId ) {
    var myRow=$("#req"+requestId);
    var parms = {
	reqid: requestId,
	msg_to: $("#oid").text(),  // message to myself
	oid: $("#oid").text(),
	status: "Message",
	message: "Requester closed the request."
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
