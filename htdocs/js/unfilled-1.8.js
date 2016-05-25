// unfilled.js
/*
    fILL - Free/Open-Source Interlibrary Loan management system
    Copyright (C) 2012  Government of Manitoba

    unfilled.js is a part of fILL.

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

    $('#unfilled-table').DataTable({
        "jQueryUI": true,
        "pagingType": "full_numbers",
        "info": true,
        "ordering": true,
        "dom": '<"H"Bfr>t<"F"ip>',
	buttons: [ 'copy', 'excel', 'pdf', 'print' ],
        "columnDefs": [ {
            "targets": [0,1,2],
            "visible": false
        },
                      ],
        "initComplete": function(settings, json) {
            // this handles a bug(?) in this version of datatables;
            // hidden columns caused the table width to be set to 100px, not 100% 
            $("#unfilled-table").css("width","100%");	    

	    $("#unfilled-table").DataTable().page.len( parseInt($("#table_rows_per_page").text(),10));

//	    while( checkOverflow( $("#myListDiv")[0] ) ) {
//                decreaseTableFontSize();
//            }
        }
	
    });

    $.getJSON('/cgi-bin/get-unfilled-list.cgi', {oid: $("#oid").text()},
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
    var t = $('#unfilled-table').DataTable();
    
    for (var i=0;i<data.unfilled.length;i++) {

	var divResponses = create_action_buttons( data, i );

	//	var statusWithWhitespace = data.unfilled[i].status;
	//	statusWithWhitespace = statusWithWhitespace.replace(/\|/g,' ');
	//        statusWithWhitespace;

	// this should match the fields in the template
	var rdata = [
            data.unfilled[i].gid,
            data.unfilled[i].cid,
            data.unfilled[i].id,
            data.unfilled[i].title,
            data.unfilled[i].author,
            data.unfilled[i].patron_barcode,
            data.unfilled[i].ts,
            data.unfilled[i].from,
            data.unfilled[i].status,
            data.unfilled[i].message,
            data.unfilled[i].pubdate,
            data.unfilled[i].tried+' of '+data.unfilled[i].sources,
	    ""
	];
	var rowNode = t.row.add( rdata ).draw().node();
	$(rowNode).attr("id",'req'+data.unfilled[i].id);
	// the :eq selector looks at *visible* nodes....
	$(rowNode).children(":eq(4)").attr("title",data.unfilled[i].library);
	$(rowNode).children(":last").append( divResponses );

	// borrower internal note:
	var row = t.row(rowNode).child( 
	    'This is a child node that we will use for internal notes', "datatable-detail"
	).show();
    }
}

function create_action_buttons( data, i ) {
    var divResponses = document.createElement("div");
    var requestId = data.unfilled[i].id;
    divResponses.id = 'divResponses'+requestId;
    
    var b1 = document.createElement("input");
    b1.type = "button";
    b1.value = "Try next lender";
    b1.className = "action-button";
    if (+data.unfilled[i].tried >= +data.unfilled[i].sources) {
	b1.value = "No further sources";
	b1.disabled = "disabled";
    }
    b1.onclick = make_trynextlender_handler( requestId );
    divResponses.appendChild(b1);
    
    var b1 = document.createElement("input");
    b1.type = "button";
    b1.value = "Cancel request";
    b1.className = "action-button";
    b1.onclick = make_cancel_handler( requestId );
    divResponses.appendChild(b1);
    
    var b1 = document.createElement("input");
    b1.type = "button";
    b1.value = "Add to wish list";
    b1.className = "action-button";
    b1.onclick = make_acq_handler( requestId );
    divResponses.appendChild(b1);
    
    return divResponses;
}

// Explanation of why we need a function to create the buttons' onclick handlers:
// http://www.webdeveloper.com/forum/archive/index.php/t-100584.html
// Short answer: scoping and closures

function make_trynextlender_handler( requestId ) {
    return function() { try_next_lender( requestId ) };
}

function try_next_lender( requestId ) {
    var myRow=$("#req"+requestId);
    var parms = {
	reqid: requestId,
	oid: $("#oid").text(),
    }
    $.getJSON('/cgi-bin/try-next-lender.cgi', parms,
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


function make_acq_handler( requestId ) {
    return function() { addToAcq( requestId ) };
}

function addToAcq( requestId ) {
    var myRow=$("#req"+requestId);
    var parms = {
	rid: requestId,
	oid: $("#oid").text(),
    }
    $.getJSON('/cgi-bin/add-request-to-acquisitions.cgi', parms,
	      function(data){
//		  alert('change request status: '+data+'\n'+parms[0].status);
	      })
	.success(function() {
	    //alert('success');
	    cancel( requestId );
	})
	.error(function() {
	    alert('error');
	})
	.complete(function() {
	    // row will get removed in cancel(), if add to acq is successful.
	});
}


