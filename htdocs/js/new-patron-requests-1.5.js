// new-patron-requests.js
/*
    fILL - Free/Open-Source Interlibrary Loan management system
    Copyright (C) 2012  Government of Manitoba

    new-patron-requests.js is a part of fILL.

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

    $('#new-patron-requests-table').DataTable({
        "jQueryUI": true,
        "pagingType": "full_numbers",
        "info": true,
        "ordering": true,
        "dom": '<"H"Bfr>t<"F"ip>',
	buttons: [ 'copy', 'excel', 'pdf', 'print' ],
        "columnDefs": [ {
            "targets": [0,8],
            "visible": false
        } ],
        "initComplete": function() {
            // this handles a bug(?) in this version of datatables;
            // hidden columns caused the table width to be set to 100px, not 100%
            $("#new-patron-requests-table").css("width","100%");
        }
    });

    $.getJSON('/cgi-bin/get-new-patron-requests.cgi', {oid: $("#oid").text()},
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
    var t = $('#new-patron-requests-table').DataTable();
    
    for (var i=0;i<data.new_patron_requests.length;i++) {

	var divResponses = create_action_buttons( data, i );

	// this should match the fields in the template
	var rdata = [
            data.new_patron_requests[i].prid,
            data.new_patron_requests[i].ts,
            data.new_patron_requests[i].name,
            data.new_patron_requests[i].card,
            data.new_patron_requests[i].title,
            data.new_patron_requests[i].author,
            data.new_patron_requests[i].medium,
            data.new_patron_requests[i].pubdate,
            data.new_patron_requests[i].isbn,
	    ""
	];
	var rowNode = t.row.add( rdata ).draw().node();
	$(rowNode).attr("id",'req'+data.new_patron_requests[i].id);
	// the :eq selector looks at *visible* nodes....
	$(rowNode).children(":eq(0)").attr("title",data.new_patron_requests[i].library);
	$(rowNode).children(":last").append( divResponses );

	// borrower internal note:
	var row = t.row(rowNode).child( 
	    'This is a child node that we will use for internal notes', "datatable-detail"
	).show();
    }
}

function create_action_buttons( data, i ) {
    var divResponses = document.createElement("div");
    var requestId = data.new_patron_requests[i].prid;
    divResponses.id = 'divResponses'+requestId;
    
    var is_verified = data.new_patron_requests[i].is_verified;

    if (!is_verified) {
	var divVerify = document.createElement("div");
	var oNewP = document.createElement("p");
	var oText = document.createTextNode("New patron, please verify");
	oNewP.appendChild(oText);
	divVerify.appendChild(oNewP);
	
	var b3 = document.createElement("input");
	b3.type = "button";
	b3.value = "Verified";
	b3.className = "action-button-highlighted";
	b3.onclick = make_verify_handler( requestId );
	divVerify.appendChild(b3);
	divResponses.appendChild(divVerify);
	
	var b4 = document.createElement("input");
	b4.type = "button";
	b4.value = "Not a patron";
	b4.className = "action-button-highlighted";
	b4.onclick = make_deverify_handler( requestId );
	divVerify.appendChild(b4);
	
	divResponses.appendChild(divVerify);
    }
    
    var b1 = document.createElement("input");
    b1.type = "button";
    b1.value = "Create ILL";
    b1.className = "action-button";
    b1.onclick = make_ILL_handler( requestId );
    if (!is_verified) {
	b1.disabled = "disabled";
    }
    divResponses.appendChild(b1);
    
    var b2 = document.createElement("input");
    b2.type = "button";
    b2.value = "Do NOT create ILL";
    b2.className = "action-button";
    b2.onclick = make_noILL_handler( requestId );
    if (!is_verified) {
	b2.disabled = "disabled";
    }
    divResponses.appendChild(b2);
    
    var b5 = document.createElement("input");
    b5.type = "button";
    b5.value = "Add to wish list";
    b5.className = "action-button";
    b5.onclick = make_acq_handler( requestId );
    if (!is_verified) {
	b5.disabled = "disabled";
    }
    divResponses.appendChild(b5);
    
    if (data.new_patron_requests[i].has_local_copy == 1) {
	var p = document.createElement("p");
	p.innerHTML = "Title held locally";
	divResponses.appendChild(p);
    }
    
    return divResponses;
}

// Explanation of why we need a function to create the buttons' onclick handlers:
// http://www.webdeveloper.com/forum/archive/index.php/t-100584.html
// Short answer: scoping and closures

function make_noILL_handler( requestId ) {
    return function() { noILL( requestId ) };
}

function noILL_orig( requestId ) {
    var myRow=$("#pr"+requestId);
    var parms = {
	prid: requestId,
	oid: $("#oid").text(),
    }
    $.getJSON('/cgi-bin/decline-patron-request.cgi', parms,
	      function(data){
//		  alert('change request status: '+data+'\n'+parms[0].status);
	      })
	.success(function() {
	    //alert('success');
	})
	.error(function() {
	    alert('error');
	})
	.complete(function() {
	    // slideUp doesn't work for <tr>
	    $("#pr"+requestId).fadeOut(400, function() { $(this).remove(); }); // toast the row
	});
}

function noILL( requestId ) {
    var row = $("#pr"+requestId);
    var rnDiv = document.createElement("div");
    rnDiv.id = "reasonNoILL";
    var rnForm = document.createElement("form");

    var rn = document.createElement("div");
    rn.setAttribute('id','noillradioset');
    rnForm.appendChild(rn);
    rnDiv.appendChild(rnForm);
    $("<tr id='tmprow'><td></td><td id='tmpcol' colspan='9'></td></tr>").insertAfter($("#pr"+requestId));
    $("#tmpcol").append(rnDiv);

    $("#divResponses"+requestId).hide();
    $( "<p>Select a reason for declining to place the ILL (your patron will be able to see this):</p>" ).insertBefore("#noillradioset");

    $("<p>Optional message to patron: <input type='text' name='message' size='40' maxlength='100' /></p>").insertAfter("#noillradioset");

    var cButton = $("<input type='button' value='Cancel' class='library-style'>").appendTo(rnForm);
    cButton.bind('click', function() {
	$("#reasonNoILL").remove(); 
	$("#tmprow").remove();
	$("#divResponses"+requestId).show(); 
	//return false;
    });

    var sButton = $("<input type='submit' value='Submit' class='library-style'>").appendTo(rnForm);
    sButton.bind('click', function() {
	var reason = $('input:radio[name=radioset]:checked').val();
	var optionalMessage = $('input:text[name=message]').val();
	$("#reasonNoILL").remove(); 
	$("#tmprow").remove();
	$("#divResponses"+requestId).show(); 
	
	var myRow=$("#pr"+requestId);
	var parms = {
	    "prid": requestId,
	    "oid": $("#oid").text(),
	    "reason": reason,
	    "message": optionalMessage
	}
	$.getJSON('/cgi-bin/decline-patron-request.cgi', parms,
		  function(data){
		      // slideUp doesn't work for <tr>
		      $("#pr"+requestId).fadeOut(400, function() { $("#pr"+requestId).remove(); }); // toast the row
		  })
	    .success(function() {
		update_menu_counters( $("#oid").text() );
	    });
	
    });

    // do this in jQuery... FF and IE handle DOM-created radiobuttons differently.
    $("#noillradioset").buttonset();
    $("#noillradioset").append("<input type='radio' name='radioset' value='held-locally' id='held-locally' checked='checked'/><label for='held-locally'>Title held locally / local hold placed</label>");
    $("#noillradioset").append("<input type='radio' name='radioset' value='blocked' id='blocked'/><label for='blocked'>Patron account blocked</label>");
    $("#noillradioset").append("<input type='radio' name='radioset' value='on-order' id='on-order'/><label for='on-order'>Title on order</label>");
    $("#noillradioset").append("<input type='radio' name='radioset' value='other' id='other'/><label for='other'>other</label>");
    $("#noillradioset").buttonset('refresh');
}


function make_ILL_handler( requestId ) {
    return function() { createILL( requestId ) };
}

function createILL( requestId ) {
    var myRow=$("#pr"+requestId);
    var parms = {
	prid: requestId,
	oid: $("#oid").text(),
    }
    $.getJSON('/cgi-bin/accept-patron-request.cgi', parms,
	      function(data){
//		  alert('accept patron request: '+data.success+'\n'+data.message+'\n');
	      })
	.success(function() {
	    //alert('success');
	})
	.error(function() {
	    alert('error');
	})
	.complete(function() {
	    // slideUp doesn't work for <tr>
	    $("#pr"+requestId).fadeOut(400, function() { $(this).remove(); }); // toast the row
	});
}


function make_verify_handler( requestId ) {
    return function() { verify( requestId ) };
}

function verify( requestId ) {
    var myRow=$("#pr"+requestId);
    var parms = {
	prid: requestId,
	oid: $("#oid").text(),
    }
    $.getJSON('/cgi-bin/verify-patron-from-request.cgi', parms,
	      function(data){
//		  alert('change request status: '+data+'\n'+parms[0].status);
	      })
	.success(function() {
	    // get rid of the divVerify, and enable the buttons:
	    $("#divResponses"+requestId+" > div").hide();
	    $("#divResponses"+requestId).children().filter(":button").removeAttr("disabled");
	})
	.error(function() {
	    alert('error');
	})
	.complete(function() {
	    // slideUp doesn't work for <tr>
	    //$("#pr"+requestId).fadeOut(400, function() { $(this).remove(); }); // toast the row
	});
}


function make_deverify_handler( requestId ) {
    return function() { deverify( requestId ) };
}

function deverify( requestId ) {
    var myRow=$("#pr"+requestId);
    var parms = {
	prid: requestId,
	oid: $("#oid").text(),
    }

    // This doesn't exist yet!  What should happen when a library anti-verifies?

    $.getJSON('/cgi-bin/deverify-patron-from-request.cgi', parms,
	      function(data){
//		  alert('change request status: '+data+'\n'+parms[0].status);
	      })
	.success(function() {
	    //alert('success');
	})
	.error(function() {
	    alert('error');
	})
	.complete(function() {
	    // slideUp doesn't work for <tr>
	    $("#pr"+requestId).fadeOut(400, function() { $(this).remove(); }); // toast the row
	});
}

function make_acq_handler( requestId ) {
    return function() { addToAcq( requestId ) };
}

function addToAcq( requestId ) {
    var myRow=$("#pr"+requestId);
    var parms = {
	prid: requestId,
	oid: $("#oid").text(),
    }
    $.getJSON('/cgi-bin/add-patron-request-to-acquisitions.cgi', parms,
	      function(data){
//		  alert('change request status: '+data+'\n'+parms[0].status);
	      })
	.success(function() {
	    //alert('success');
	    var parms = {
		"prid": requestId,
		"oid": $("#oid").text(),
		"reason": 'Your librarian is considering this for purchase.',
		"message": ''
	    }
	    $.getJSON('/cgi-bin/decline-patron-request.cgi', parms,
		      function(data){
			  //
		      })
		.success(function() {
		});
	})
	.error(function() {
	    alert('error');
	})
	.complete(function() {
	    // slideUp doesn't work for <tr>
	    $("#pr"+requestId).fadeOut(400, function() { $(this).remove(); }); // toast the row
	    update_menu_counters( $("#oid").text() );
	});
}


