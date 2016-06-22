// renewal-answer.js
/*
    fILL - Free/Open-Source Interlibrary Loan management system
    Copyright (C) 2012  Government of Manitoba

    renewal-answer.js is a part of fILL.

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

    $('#renewal-answer-table').DataTable({
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
            $("#renewal-answer-table").css("width","100%");

	    $("#renewal-answer-table").DataTable().page.len( parseInt($("#table_rows_per_page").text(),10));
        }
    });

    $.getJSON('/cgi-bin/get-renewal-requests.cgi', {oid: $("#oid").text()},
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
    var t = $('#renewal-answer-table').DataTable();
    
    // Need to create a default due date:
    var now = new Date();
    var d = new Date(now.getTime() + (27 * 24 * 60 * 60 * 1000)); 
    // Doesn't work on older version of Internet Explorer...
    //	var iso = d.toISOString();
    var month = d.getMonth()+1;
    var day = d.getDate();
    var iso = d.getFullYear() + '-' +
	((''+month).length<2 ? '0' : '') + month + '-' +
	((''+day).length<2 ? '0' : '') + day;

    for (var i=0;i<data.renewRequests.length;i++) {

	var divResponses = create_action_buttons( data, i );

	// this should match the fields in the template
	var rdata = [
            data.renewRequests[i].gid,
            data.renewRequests[i].cid,
            data.renewRequests[i].id,
            data.renewRequests[i].from,
	    data.renewRequests[i].msg_from,
	    data.renewRequests[i].call_number,
	    data.renewRequests[i].author,
	    data.renewRequests[i].title,
	    data.renewRequests[i].ts,
	    data.renewRequests[i].original_due_date,
	    "", // inline date goes here
	    ""
	];
	
	var requestId = data.renewRequests[i].id;
	var dd=$("<input/>").attr({ type: "text",
				    id: 'dd'+requestId,
				    size: "10" }
				 ).val(iso.substring(0,10));
	dd.datepicker({ dateFormat: 'yy-mm-dd' });

	var rowNode = t.row.add( rdata ).draw().node();
	$(rowNode).attr("id",'req'+data.renewRequests[i].id);
	// the :eq selector looks at *visible* nodes....
	$(rowNode).children(":eq(0)").attr("title",data.renewRequests[i].library);
	$(rowNode).children(":eq(6)").replaceWith( dd );
	$(rowNode).children(":eq(6)").addClass('due-date');
	$(rowNode).children(":last").append( divResponses );

	lenderNotes_insertChild( t, rowNode,
				 data.renewRequests[i].lender_internal_note,
				 "datatable-detail"
			       );
    }

    lenderNotes_makeEditable();
}

function create_action_buttons( data, i ) {
    var requestId = data.renewRequests[i].id;
    var divResponses = document.createElement("div");
    divResponses.id = 'divResponses'+requestId;

    var b1 = document.createElement("input");
    b1.type = "button";
    b1.id = "renew"+requestId;
    b1.value = "Renew OK";
    // class renew-it-button is used in function set_default_due_date()
    b1.className = "action-button renew-it-button";
    b1.onclick = make_renewalAnswer_handler( requestId );
    divResponses.appendChild(b1);
    
    var b2 = document.createElement("input");
    b2.type = "button";
    b2.id = "norenew"+requestId;
    b2.value = "Can\'t renew";
    // class no-renew-button is used in function set_default_due_date()
    b2.className = "action-button no-renew-button";
    b2.onclick = make_cannotRenew_handler( requestId );
    divResponses.appendChild(b2);
    
    return divResponses;
}

// Explanation of why we need a function to create the buttons' onclick handlers:
// http://www.webdeveloper.com/forum/archive/index.php/t-100584.html
// Short answer: scoping and closures

function make_renewalAnswer_handler( requestId ) {
    return function() { renewalAnswer( requestId ) };
}

function renewalAnswer( requestId ) {
    var myRow=$("#req"+requestId);
    var nTr = myRow[0]; // convert jQuery object to DOM
    var oTable = $('#renewal-answer-table').dataTable();
    var aPos = oTable.fnGetPosition( nTr );
    var msg_to = oTable.fnGetData( aPos )[4]; // 5th column (0-based!), hidden or not
//    var due_date = oTable.fnGetData( aPos )[9];
    var due_date = $("#dd"+requestId).val();
    
    if (due_date.length == 0) {
	var retVal = confirm("You have not entered a due date.  Continue without due date?");
	if (retVal == false) {
	    // bail out to let the user enter a due date
 	    return false;
	}
    }

    var parms = {
	"reqid": requestId,
	"msg_to": msg_to,
	"oid": $("#oid").text(),
	"status": "Renew-Answer|Ok",
	"message": "due "+due_date
    };
    $.getJSON('/cgi-bin/change-request-status.cgi', parms,
	      function(data){
		  //alert('change request status: '+data+'\n'+parms.status);
	      })
        .success(function() {
	    update_menu_counters( $("#oid").text() );
	})
	.error(function() {
	    alert('error');
	})
	.complete(function() {
	    // toast any child nodes (eg lender internal notes)
	    var t = $("#renewal-answer-table").DataTable();
	    t.row("#req"+requestId).child.remove();
	    // slideUp doesn't work for <tr>
	    $("#req"+requestId).fadeOut(400, function() { $(this).remove(); }); // toast the row
	});
}

function make_cannotRenew_handler( requestId ) {
    return function() { cannotRenew( requestId ) };
}

function cannotRenew( requestId ) {
    var myRow=$("#req"+requestId);
    var nTr = myRow[0]; // convert jQuery object to DOM
    var oTable = $('#renewal-answer-table').dataTable();
    var aPos = oTable.fnGetPosition( nTr );
    var msg_to = oTable.fnGetData( aPos )[4]; // 5th column (0-based!), hidden or not

    var crDiv = document.createElement("div");
    crDiv.id = "cannotRenewMessage";
    var crForm = document.createElement("form");
    crDiv.appendChild(crForm);
    $("#divResponses"+requestId).after( crDiv ); // crDiv is sibling of divResponses

    $("#divResponses"+requestId).hide();

    $("<p />").text("You can enter a message if you'd like:").appendTo(crForm);
    $("<input />").attr({'type':'text','id':'crmsg'}).appendTo(crForm);
    var cButton = $("<input type='button' class='action-button' value='Cancel'>").appendTo(crForm);
    cButton.bind('click', function() {
	$("#cannotRenewMessage").remove(); 
	$("#divResponses"+requestId).show(); 
	//return false;
    });

    var sButton = $("<input type='button' class='action-button' value='Submit'>").appendTo(crForm);
    sButton.bind('click', function() {
	var reason = $('#crmsg').val();
	//alert( reason );
	$("#cannotRenewMessage").remove(); 
	$("#divResponses"+requestId).show(); 
	var parms = {
	    "reqid": requestId,
	    "msg_to": msg_to,
	    "oid": $("#oid").text(),
	    "status": "Renew-Answer|No-renewal",
	    "message": reason
	};

	$.getJSON('/cgi-bin/change-request-status.cgi', parms,
		  function(data){
		      //alert('change request status: '+data+'\n'+parms.status);
		  })
            .success(function() {
		//alert('success');
	    })
	    .error(function() {
		alert('error');
	    })
	    .complete(function() {
		// toast any child nodes (eg lender internal notes)
		var t = $("#renewal-answer-table").DataTable();
		t.row("#req"+requestId).child.remove();
		// slideUp doesn't work for <tr>
		$("#req"+requestId).fadeOut(400, function() { $(this).remove(); }); // toast the row
	    });
    });
}

function set_default_due_date(oForm) {
    var defaultDueDate = $("#datepicker").datepicker("getDate");
    $(".due-date").datepicker( "setDate", defaultDueDate );
    $(".due-date").stop(true,true).effect("highlight", {}, 2000);
}
