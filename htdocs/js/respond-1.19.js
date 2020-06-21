// respond.js
/*
    fILL - Free/Open-Source Interlibrary Loan management system
    Copyright (C) 2012  Government of Manitoba

    respond.js is a part of fILL.

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

    $('#respond-table').DataTable({
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
            $("#respond-table").css("width","100%");

	    $("#respond-table").DataTable().page.len( parseInt($("#table_rows_per_page").text(),10));
        }
    });

    $.getJSON('/cgi-bin/get-respond-list.cgi', {oid: $("#oid").text()},
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

    $("#bToggleUnfilledCodes").on("click", function() {
	$("#unfilled-codes").toggle();
	if ( $("#unfilled-codes").is(":visible") ) {
	    $("#bToggleUnfilledCodes").prop('value',"Hide the Unfilled codes");
        } else {
	    $("#bToggleUnfilledCodes").prop('value',"Show the Unfilled codes");
        }
    });

});

function build_table( data ) {
    var t = $('#respond-table').DataTable();
    
    for (var i=0;i<data.unhandledRequests.length;i++) {

	var divResponses = create_action_buttons( data, i );

	// this should match the fields in the template
	var rdata = [
	    data.unhandledRequests[i].gid,
	    data.unhandledRequests[i].cid,
	    data.unhandledRequests[i].id,
	    data.unhandledRequests[i].from,
	    data.unhandledRequests[i].msg_from,
	    data.unhandledRequests[i].call_number,
	    data.unhandledRequests[i].author,
	    data.unhandledRequests[i].title,
	    data.unhandledRequests[i].note,
	    data.unhandledRequests[i].ts,
	    data.unhandledRequests[i].medium,
	    data.unhandledRequests[i].pubdate,
	    data.unhandledRequests[i].place_on_hold,
	    ""
	];
	var rowNode = t.row.add( rdata ).draw().node();
	$(rowNode).attr("id",'req'+data.unhandledRequests[i].id);
	// the :eq selector looks at *visible* nodes....
	$(rowNode).children(":eq(0)").attr("title",data.unhandledRequests[i].library);
	if (data.unhandledRequests[i].opt_in == false) { // have not opted in for ILL
	    $(rowNode).children(":eq(0)").addClass("ill-status-no");
	    $(rowNode).children(":eq(0)").attr("title",data.unhandledRequests[i].library+" is not open for ILL");
	}
	$(rowNode).children(":last").append( divResponses );

	lenderNotes_insertChild( t, rowNode,
				 data.unhandledRequests[i].lender_internal_note,
				 "datatable-detail"
			       );
    }
    lenderNotes_makeEditable();
}

function create_action_buttons( data, i ) {
    var divResponses = document.createElement("div");
    var requestId = data.unhandledRequests[i].id;
    divResponses.id = 'divResponses'+requestId;
    
    if (data.unhandledRequests[i].opt_in == true) {  // available for ILL
	var b1 = document.createElement("input");
	b1.type = "button";
	b1.value = "Will-supply";
	b1.className = "action-button";
	b1.onclick = make_shipit_handler( requestId );
	divResponses.appendChild(b1);
	
	if (data.canForwardToSiblings) {
	    var b2 = document.createElement("input");
	    b2.type = "button";
	    b2.value = "Forward to branch";
	    b2.className = "action-button";
	    b2.onclick = make_forward_handler( requestId, data.retargets );
	    divResponses.appendChild(b2);
	}
	
	var b3 = document.createElement("input");
	b3.type = "button";
	b3.value = "Unfilled";
	b3.className = "action-button";
	b3.onclick = make_unfilled_handler( requestId );
	divResponses.appendChild(b3);
	
	if (data.unhandledRequests[i].place_on_hold != "no") {
	    var b4 = document.createElement("input");
	    b4.type = "button";
	    b4.value = "Hold placed";
	    b4.className = "action-button";
	    b4.onclick = make_hold_placed_handler( requestId );
	    divResponses.appendChild(b4);
	}
    } else {
	// The requesting library is not open for ILL.  This library can
	// still respond with "unfilled".
	var $noILL = $("<p>"+data.unhandledRequests[i].library+" is not open for ILL.</p>");
	divResponses.appendChild( $noILL[0] );
	var b3 = document.createElement("input");
	b3.type = "button";
	b3.value = "Unfilled";
	b3.className = "action-button";
	b3.onclick = make_unfilled_handler( requestId );
	divResponses.appendChild(b3);
    }
    return divResponses;
}

// Explanation of why we need a function to create the buttons' onclick handlers:
// http://www.webdeveloper.com/forum/archive/index.php/t-100584.html
// Short answer: scoping and closures

function make_hold_placed_handler( requestId ) {
    return function() { holdplaced( requestId ) };
}

function holdplaced( requestId ) {
    var myRow=$("#req"+requestId);
    var nTr = myRow[0]; // convert jQuery object to DOM
    var oTable = $('#respond-table').dataTable();
    var aPos = oTable.fnGetPosition( nTr );
    var msg_to = oTable.fnGetData( aPos )[4]; // 5th column (0-based!), hidden or not

    var hpDiv = document.createElement("div");
    hpDiv.id = "expectedDate";
    var hpForm = document.createElement("form");

    var hp = document.createElement("div");
    hp.setAttribute('id','setDate');
    hpForm.appendChild(hp);
    hpDiv.appendChild(hpForm);
    $("<tr id='tmprow'><td></td><td id='tmpcol' colspan='13'></td></tr>").insertAfter($("#req"+requestId));
    $("#tmpcol").append(hpDiv);

    $("#divResponses"+requestId).hide();
    $( "<p>What date do you expect the hold to be filled?</p>" ).insertBefore("#setDate");

    $("<p><input id='dateAvailable' type='text' size='12' maxlength='12' /></p>").insertAfter("#setDate");

    var dateAvailable = moment();
    dateAvailable = dateAvailable.add('months',1);
    
    $("#dateAvailable").datepicker({ dateFormat: 'yy-mm-dd', defaultDate: '+1m' });
    $("#dateAvailable").datepicker('setDate', dateAvailable.native() );
    

    var cButton = $("<input type='button' class='library-style' value='Cancel'>").appendTo(hpForm);
    cButton.bind('click', function() {
	$("#expectedDate").remove(); 
	$("#tmprow").remove();
	$("#divResponses"+requestId).show(); 
	//return false;
    });

    var sButton = $("<input type='submit' class='library-style' value='Submit'>").appendTo(hpForm);
    sButton.bind('click', function() {
        var expected = moment( $("#dateAvailable").datepicker("getDate") ).format("YYYY-MM-DD");
	$("#expectedDate").remove(); 
	$("#tmprow").remove();
	$("#divResponses"+requestId).show(); 
	
	var myRow=$("#req"+requestId);
	var parms = {
	    "reqid": requestId,
	    "msg_to": msg_to,  // sending TO whoever original was FROM
	    "oid": $("#oid").text(),
	    "status": "ILL-Answer|Hold-Placed|estimated-date-available",
	    "message": expected
	};
	$.getJSON('/cgi-bin/change-request-status.cgi', parms,
		  function(data){
		      // toast any child nodes (eg lender internal notes)
		      var t = $("#respond-table").DataTable();
		      t.row("#req"+requestId).child.remove();
		      // slideUp doesn't work for <tr>
		      $("#req"+requestId).fadeOut(400, function() { $("req"+requestId).remove(); }); // toast the row
		  })
	    .success(function() {
		update_menu_counters( $("#oid").text() );
	    });
	
    });
}

function make_shipit_handler( requestId ) {
    return function() { shipit( requestId ) };
}

function shipit( requestId ) {
    var myRow=$("#req"+requestId);
    var nTr = myRow[0]; // convert jQuery object to DOM
    var oTable = $('#respond-table').dataTable();
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
	    // toast any child nodes (eg lender internal notes)
	    var t = $("#respond-table").DataTable();
	    t.row("#req"+requestId).child.remove();
	    // slideUp doesn't work for <tr>
	    $("#req"+requestId).fadeOut(400, function() { $(this).remove(); }); // toast the row
	});
}

function make_unfilled_handler( requestId ) {
    return function() { unfilled( requestId ) };
}

function unfilled( requestId ) {
    var row = $("#req"+requestId);
    var nTr = row[0]; // convert jQuery object to DOM
    var oTable = $('#respond-table').dataTable();
    var aPos = oTable.fnGetPosition( nTr );
    var msg_to = oTable.fnGetData( aPos )[4]; // 5th column (0-based!), hidden or not

    var ruDiv = document.createElement("div");
    ruDiv.id = "reasonUnfilled";
    var ruForm = document.createElement("form");

    var ru = document.createElement("div");
    ru.setAttribute('id','unfilledradioset');
    ruForm.appendChild(ru);
    ruDiv.appendChild(ruForm);
    $("<tr id='tmprow'><td></td><td id='tmpcol' colspan='9'></td></tr>").insertAfter($("#req"+requestId));
    $("#tmpcol").append(ruDiv);

    $("#divResponses"+requestId).hide();
    $( "<p>Select the reason that you cannot fill:</p>" ).insertBefore("#unfilledradioset");

    $("<p>Optional message to borrower: <input type='text' name='message' size='40' maxlength='100' /></p>").insertAfter("#unfilledradioset");

    var cButton = $("<input type='button' class='library-style' value='Cancel'>").appendTo(ruForm);
    cButton.bind('click', function() {
	$("#reasonUnfilled").remove(); 
	$("#tmprow").remove();
	$("#divResponses"+requestId).show(); 
	//return false;
    });

    var sButton = $("<input type='submit' class='library-style' value='Submit'>").appendTo(ruForm);
    sButton.bind('click', function() {
	var reason = $('input:radio[name=radioset]:checked').val();
	var optionalMessage = $('input:text[name=message]').val();
	$("#reasonUnfilled").remove(); 
	$("#tmprow").remove();
	$("#divResponses"+requestId).show(); 
	
	var myRow=$("#req"+requestId);
	var parms = {
	    "reqid": requestId,
	    "msg_to": msg_to,  // sending TO whoever original was FROM
	    "oid": $("#oid").text(),
	    "status": "ILL-Answer|Unfilled|"+reason,
	    "message": optionalMessage
	};
	$.getJSON('/cgi-bin/change-request-status.cgi', parms,
		  function(data){
		      // toast any child nodes (eg lender internal notes)
		      var t = $("#respond-table").DataTable();
		      t.row("#req"+requestId).child.remove();
		      // slideUp doesn't work for <tr>
		      $("#req"+requestId).fadeOut(400, function() { $("req"+requestId).remove(); }); // toast the row
		  })
	    .success(function() {
		update_menu_counters( $("#oid").text() );
	    });
	
    });

    // do this in jQuery... FF and IE handle DOM-created radiobuttons differently.
    $("#unfilledradioset").buttonset();
    $("#unfilledradioset").append("<input type='radio' name='radioset' value='in-use-on-loan' id='in-use-on-loan' checked='checked'/><label for='in-use-on-loan'>in-use-on-loan</label>");
    $("#unfilledradioset").append("<input type='radio' name='radioset' value='in-process' id='in-process'/><label for='in-process'>in-process</label>");
    $("#unfilledradioset").append("<input type='radio' name='radioset' value='lost' id='lost'/><label for='lost'>lost</label>");
    $("#unfilledradioset").append("<input type='radio' name='radioset' value='non-circulating' id='non-circulating'/><label for='non-circulating'>non-circulating</label>");
    $("#unfilledradioset").append("<input type='radio' name='radioset' value='not-owned' id='not-owned'/><label for='not-owned'>not-owned</label>");
    $("#unfilledradioset").append("<input type='radio' name='radioset' value='on-order' id='on-order'/><label for='on-order'>on-order</label>");
    $("#unfilledradioset").append("<input type='radio' name='radioset' value='not-on-shelf' id='not-on-shelf'/><label for='not-on-shelf'>not-on-shelf</label>");
    $("#unfilledradioset").append("<input type='radio' name='radioset' value='on-reserve' id='on-reserve'/><label for='on-reserve'>on-reserve</label>");
    $("#unfilledradioset").append("<input type='radio' name='radioset' value='poor-condition' id='poor-condition'/><label for='poor-condition'>poor-condition</label>");
    $("#unfilledradioset").append("<input type='radio' name='radioset' value='charges' id='charges'/><label for='charges'>charges</label>");
    $("#unfilledradioset").append("<input type='radio' name='radioset' value='on-hold' id='on-hold'/><label for='on-hold'>on-hold</label>");
    $("#unfilledradioset").append("<input type='radio' name='radioset' value='policy-problem' id='policy-problem'/><label for='policy-problem'>policy-problem</label>");
    $("#unfilledradioset").append("<input type='radio' name='radioset' value='other' id='other'/><label for='other'>other</label>");
//    $("#unfilledradioset").append("<input type='radio' name='radioset' value='responder-specific' id='responder-specific'/><label for='responder-specific'>responder-specific</label>");
    $("#unfilledradioset").buttonset('refresh');
}

function make_forward_handler( requestId, retargets ) {
    return function() { forward( requestId, retargets ) };
}

function forward( requestId, retargets ) {
    var row = $("#req"+requestId);
    var nTr = row[0]; // convert jQuery object to DOM
    var oTable = $('#respond-table').dataTable();
    var aPos = oTable.fnGetPosition( nTr );
    var msg_to = oTable.fnGetData( aPos )[4]; // 5th column (0-based!), hidden or not

    var ruDiv = document.createElement("div");
    ruDiv.id = "branchForward";
    var ruForm = document.createElement("form");

    var ru = document.createElement("div");
    ru.setAttribute('id','forwardradioset');
    ruForm.appendChild(ru);
    ruDiv.appendChild(ruForm);
    $("<tr id='tmprow'><td></td><td id='tmpcol' colspan='11'></td></tr>").insertAfter($("#req"+requestId));
    $("#tmpcol").append(ruDiv);

    $("#divResponses"+requestId).hide();
    $( "<p>Select the branch to foward this request to:</p>" ).insertBefore("#forwardradioset");


    var cButton = $("<input type='button' class='library-style' value='Cancel'>").appendTo(ruForm);
    cButton.bind('click', function() {
	$("#branchForward").remove(); 
	$("#tmprow").remove();
	$("#divResponses"+requestId).show(); 
	//return false;
    });

    var sButton = $("<input type='submit' class='library-style' value='Submit'>").appendTo(ruForm);
    sButton.bind('click', function() {
	var forwardTo = $('input:radio[name=radioset]:checked').val();
	$("#branchForward").remove(); 
	$("#tmprow").remove();
	$("#divResponses"+requestId).show(); 
	
	var parms = $('#respond-table tbody tr').map(function() {
	    // $(this) is used more than once; cache it for performance.
	    var $row = $(this);
	    var nTr = row[0]; // convert jQuery object to DOM
	    var oTable = $('#respond-table').dataTable();
	    var aPos = oTable.fnGetPosition( nTr );
	    var reqid = oTable.fnGetData( aPos )[2]; // 3rd column (0-based!), hidden or not
	    if (reqid == requestId) {
		var targetIndex;
		for (var i=0; i < retargets.length; i++) {
		    if (retargets[i].oid == forwardTo)
			targetIndex = i;
		}
		return {
		    reqid: requestId,
		    msg_to: msg_to,  // sending TO whoever original was FROM
		    oid: $("#oid").text(),
		    status: "ILL-Answer|Locations-provided|responder-specific",
		    message: "forwarded to our branch "+retargets[targetIndex].org_name
		}
	    } else {
		return null;
	    };
	}).get();

	$.getJSON('/cgi-bin/change-request-status.cgi', parms[0],
		  function(data){
		      // create request from borrower to new lender
		      $.getJSON('/cgi-bin/change-request-status.cgi',
				{ reqid: requestId,
				  msg_to: forwardTo,
				  oid: parms[0].msg_to,  // sending FROM whoever original was FROM (which is whoever we sent the response to)
				  status: "ILL-Request",
				  message: ""
				},
				function() {
				    // toast any child nodes (eg lender internal notes)
				    var t = $("#respond-table").DataTable();
				    t.row("#req"+requestId).child.remove();
				    // slideUp doesn't work for <tr>
				    $("#req"+requestId).fadeOut(400, function() { $("req"+requestId).remove(); }); // toast the row
				})
			  .error(function() {
			      alert('Could not create new ILL-Request.');
			  });
		  })
	    .success(function() {
		$.getJSON('/cgi-bin/update-source-on-forward.cgi',
			  { reqid: requestId,
			    hq: $("#oid").text(),
			    branch: forwardTo
			  },
			  function() {
			      //alert("sources updated - branch is now source");
			  });
		update_menu_counters( $("#oid").text() );
	    });
	
    });

    // do this in jQuery... FF and IE handle DOM-created radiobuttons differently.
    $("#forwardradioset").buttonset();

    var iFirst;
    for (var i = 0; i < retargets.length; i++) {
	if (retargets[i].city) {
	    if (typeof iFirst == 'undefined') { iFirst = i; }
	    var s="<input type='radio' name='radioset' value='"+retargets[i].oid+"' id='"+retargets[i].oid+"'/><label for='"+retargets[i].oid+"'>"+retargets[i].city+"</label>";
	    $("#forwardradioset").append(s);
	}
    }

    $("#forwardradioset").buttonset('refresh');
    $("#"+retargets[iFirst].oid).prop("checked",true).button('refresh');
}
