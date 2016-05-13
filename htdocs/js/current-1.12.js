// current.js
/*
    fILL - Free/Open-Source Interlibrary Loan management system
    Copyright (C) 2012  Government of Manitoba

    current.js is a part of fILL.

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
    set_primary_tab("menu_current");

    // From https://localhost/plugins/DataTables-1.10.2/examples/api/tabs_and_scrolling.html
    $("#tabs").tabs( {
        "activate": function(event, ui) {
            $( $.fn.dataTable.tables( true ) ).DataTable().columns.adjust();
        }
    } );
  
    var sImageUrl = "/img/";

    //-----------------------------------------------------------------------------
    $('#datatable_borrowing').DataTable({
        "jQueryUI": true,
        "pagingType": "full_numbers",
        "info": true,
      	"ordering": true,
	"dom": '<"H"Bfr>t<"F"ip>',
	buttons: [ 'copy', 'excel', 'pdf', 'print' ],
        "columnDefs": [
	    { "targets": 0,
              "data": null,
              "defaultContent": '<img src="'+sImageUrl+'details_open.png'+'">',
              "className": "control center"
            },
            { "targets": [1,2],
	      "visible": false
            },
	    { "targets": -1,
	      "data": null,
	      "defaultContent": '<img src="'+sImageUrl+'details_open.png'+'">',
	      "className": "overrides center"
            }],
        "initComplete": function() {
            // this handles a bug(?) in this version of datatables;
            // hidden columns caused the table width to be set to 100px, not 100%
            $("#datatable_borrowing").css("width","100%");
        }
    });
    
    //-----------------------------------------------------------------------------
    $('#datatable_lending').DataTable({
        "jQueryUI": true,
        "pagingType": "full_numbers",
        "info": true,
        "ordering": true,
 	"dom": '<"H"Bfr>t<"F"ip>',
	buttons: [ 'copy', 'excel', 'pdf', 'print' ],
        "columnDefs": [
	    { "targets": 0,
              "data": null,
              "defaultContent": '<img src="'+sImageUrl+'details_open.png'+'">',
              "className": "control center"
            },
            { "targets": 1,
	      "visible": false
            },
            { "targets": -1,
	      "data": null,
	      "defaultContent": '<img src="'+sImageUrl+'details_open.png'+'">',
	      "className": "overrides center"
            }],
        "initComplete": function() {
            // this handles a bug(?) in this version of datatables;
            // hidden columns caused the table width to be set to 100px, not 100%
            $("#datatable_lending").css("width","100%");
        }
    });
    
    //-----------------------------------------------------------------------------
    $('#datatable_notfilled').DataTable({
        "jQueryUI": true,
        "pagingType": "full_numbers",
        "info": true,
      	"ordering": true,
	"dom": '<"H"Bfr>t<"F"ip>',
	buttons: [ 'copy', 'excel', 'pdf', 'print' ],
        "columnDefs": [
	    { "targets": 0,
              "data": null,
              "defaultContent": '<img src="'+sImageUrl+'details_open.png'+'">',
              "className": "control center"
            },
            { "targets": 1,
	      "visible": false
            }],
        "initComplete": function() {
            // this handles a bug(?) in this version of datatables;
            // hidden columns caused the table width to be set to 100px, not 100%
            $("#datatable_notfilled").css("width","100%");
        }
    });
    

    //-----------------------------------------------------------------------------
    $.getJSON('/cgi-bin/get-current-requests.cgi', {oid: $("#oid").text()},
            function(data){
		build_table_borrowing( data );
		build_table_lending( data );
		build_table_notfilled( data );
		
		$("#waitDiv").hide();
		$("#tabs").show();
            })
	.success(function() {
	    //alert('success');
	})
	.error(function() {
	    alert('error');
	})
	.complete(function() {
	});  // end of .complete()

    //-----------------------------------------------------------------------------
    $('#datatable_borrowing tbody').on('click', 'td.control', function () {
	var table = $('#datatable_borrowing').DataTable();
	
	var tr = $(this).parents('tr');
	var row = table.row( tr );

	var d = table.row(this).data();
	var parms = { "cid": d[2] }; // borrowing, cid is 2; lending/notfilled it's 1
	$.getJSON('/cgi-bin/get-current-request-details.cgi', parms,
		  function(data){
		      if (row.child.isShown()){
			  $('div.innerDetails', row.child()).slideUp( function () {
			      row.child.hide();
			      tr.removeClass('details');
			  });
		      }
		      else {
			  tr.addClass('details');
			  row.child( format(data) ).show();
			  $('div.innerDetails', row.child()).slideDown();
		      }
		  })
	    .success(function() {
		//alert('success');
	    })
	    .error(function() {
		alert('error');
	    })
	    .complete(function() {
	    });

    });  // end of .on('click')
    
    //-----------------------------------------------------------------------------
    $('#datatable_borrowing tbody').on('click', 'td.overrides', function () {
	var table = $('#datatable_borrowing').DataTable();
	
	var tr = $(this).parents('tr');
	var row = table.row( tr );

	var d = table.row(this).data();
	var parms = { "cid": d[2] }; // borrowing, cid is 2; lending/notfilled it's 1

	if (row.child.isShown()){
	    $('div.innerDetails', row.child()).slideUp( function () {
		row.child.hide();
		tr.removeClass('details');
	    });
	}
	else {
	    tr.addClass('details');
	    row.child( formatBorrowingOverrides( parms ) ).show();
	    $('div.innerDetails', row.child()).slideDown();

	    $('#bReceive').button();
	    $('#bReceive').click(function() { 
		var hasConfirmed = confirm("Overrides are a last resort.\n\nIf you have tried to contact the lender but had no response, click 'Ok' to force this action.\n\nOtherwise, please click 'Cancel', contact them, and ask them to mark the request as 'Shipped'.");
		if (hasConfirmed == true) {
		    override( this, parms.cid, null, table, row );
		    $('div.innerDetails', row.child()).slideUp( function () {
			row.child.hide();
			tr.removeClass('details');
		    });
		}
		return false; 
	    });
	    $('#bLost').button();
	    $('#bLost').click(function() { 
		var borrowerMessage = prompt("Please enter a message for the lender:");
		if (borrowerMessage != null) {
		    override( this, parms.cid, borrowerMessage, table, row );
		    $('div.innerDetails', row.child()).slideUp( function () {
			row.child.hide();
			tr.removeClass('details');
		    });
		}
		return false; 
	    });
	    $('#bClose').button();
	    $('#bClose').click(function() { 
		var hasConfirmed = confirm("Overrides are a last resort.\n\nIf you have tried to contact the lender but had no response, click 'Ok' to force this action.\n\nOtherwise, please click 'Cancel', contact them, and ask them to mark the request as 'Checked-in'.");
		if (hasConfirmed == true) {
		    override( this, parms.cid, null, table, row );
		    $('div.innerDetails', row.child()).slideUp( function () {
			row.child.hide();
			tr.removeClass('details');
		    });
		    row.remove().draw();
		}
		return false; 
	    });
	}
    });  // end of .on('click')
    
    //-----------------------------------------------------------------------------
    $('#datatable_lending tbody').on('click', 'td.control', function () {
	var table = $('#datatable_lending').DataTable();
	
	var tr = $(this).parents('tr');
	var row = table.row( tr );

	var d = table.row(this).data();
	var parms = { "cid": d[1] }; // borrowing, cid is 2; lending/notfilled it's 1
	$.getJSON('/cgi-bin/get-current-request-details.cgi', parms,
		  function(data){
		      if (row.child.isShown()){
			  $('div.innerDetails', row.child()).slideUp( function () {
			      row.child.hide();
			      tr.removeClass('details');
			  });
		      }
		      else {
			  tr.addClass('details');
			  row.child( format(data) ).show();
			  $('div.innerDetails', row.child()).slideDown();
		      }
		  })
	    .success(function() {
		//alert('success');
	    })
	    .error(function() {
		alert('error');
	    })
	    .complete(function() {
	    });

    });  // end of .on('click')
    
    //-----------------------------------------------------------------------------
    $('#datatable_lending tbody').on('click', 'td.overrides', function () {
	var table = $('#datatable_lending').DataTable();
	
	var tr = $(this).parents('tr');
	var row = table.row( tr );

	var d = table.row(this).data();
	var parms = { "cid": d[1] }; // borrowing, cid is 2; lending/notfilled it's 1
	if (row.child.isShown()){
	    $('div.innerDetails', row.child()).slideUp( function () {
		row.child.hide();
		tr.removeClass('details');
	    });
	}
	else {
	    tr.addClass('details');
	    row.child( formatLendingOverrides( parms) ).show();
	    $('div.innerDetails', row.child()).slideDown();

	    $('#bReturned').button();
	    $('#bReturned').click(function() { 
		var hasConfirmed = confirm("Overrides are a last resort.\n\nIf you have tried to contact the borrower but had no response, click 'Ok' to force this action.\n\nOtherwise, please click 'Cancel', contact them, and ask them to mark the request as 'Returned'.");
		if (hasConfirmed == true) {
		    override( this, parms.cid, null, table, row );
		    $('div.innerDetails', row.child()).slideUp( function () {
			row.child.hide();
			tr.removeClass('details');
		    });
		}
		return false; 
	    });
	    
	    $("#bDueDate")
		.button()
		.click(function() {
		    $( "#dialog-form" )
			.data('fromButton',this)
			.data('cid',parms.cid)
			.data('table',table)
			.data('row',row)
			.dialog( "open" );
		});
	    
	}

    });  // end of .on('click')
    
    //-----------------------------------------------------------------------------
    $('#datatable_notfilled tbody').on('click', 'td.control', function () {
	var table = $('#datatable_notfilled').DataTable();
	
	var tr = $(this).parents('tr');
	var row = table.row( tr );

	var d = table.row(this).data();
	var parms = { "cid": d[1] }; // borrowing, cid is 2; lending/notfilled it's 1
	$.getJSON('/cgi-bin/get-current-request-details.cgi', parms,
		  function(data){
		      if (row.child.isShown()){
			  $('div.innerDetails', row.child()).slideUp( function () {
			      row.child.hide();
			      tr.removeClass('details');
			  });
		      }
		      else {
			  tr.addClass('details');
			  row.child( format(data) ).show();
			  $('div.innerDetails', row.child()).slideDown();
		      }
		  })
	    .success(function() {
		//alert('success');
	    })
	    .error(function() {
		alert('error');
	    })
	    .complete(function() {
	    });

    });  // end of .on('click')
    

});

//-----------------------------------------------------------------------------
function build_table_borrowing( data ) {
    var t = $('#datatable_borrowing').DataTable();
    
    for (var i=0;i<data.active.borrowing.length;i++) {

	// this should match the fields in the template
	var rdata = [
            "",
            data.active.borrowing[i].gid,
            data.active.borrowing[i].cid,
            data.active.borrowing[i].title,
            data.active.borrowing[i].author,
            data.active.borrowing[i].patron_barcode,
            data.active.borrowing[i].lender,
            data.active.borrowing[i].ts,
            data.active.borrowing[i].status,
            data.active.borrowing[i].message,
            ""
	];
	var rowNode = t.row.add( rdata ).draw().node();
	$(rowNode).attr("id",'borr'+data.active.borrowing[i].gid+'-'+data.active.borrowing[i].cid);
	// the :eq selector looks at *visible* nodes....
	$(rowNode).children(":eq(4)").attr("title",data.active.borrowing[i].library);
    }
}

//-----------------------------------------------------------------------------
function build_table_lending( data ) {
    var t = $('#datatable_lending').DataTable();

    for (var i=0;i<data.active.lending.length;i++) {

	// this should match the fields in the template
	var rdata = [
            null,
            data.active.lending[i].cid,
            data.active.lending[i].title,
            data.active.lending[i].author,
            data.active.lending[i].requested_by,
	    data.active.lending[i].ts,
	    data.active.lending[i].status,
	    data.active.lending[i].message,
	    null
	];
	var rowNode = t.row.add( rdata ).draw().node();
	$(rowNode).attr("id",'lend'+data.active.lending[i].cid);
	// the :eq selector looks at *visible* nodes....
	$(rowNode).children(":eq(3)").attr("title",data.active.lending[i].library);
    }
}

//-----------------------------------------------------------------------------
function build_table_notfilled( data ) {
    var t = $('#datatable_notfilled').DataTable();

    for (var i=0;i<data.active.notfilled.length;i++) {

        // this should match the fields in the template
	var rdata = [
	    null,
            data.active.notfilled[i].cid,
            data.active.notfilled[i].title,
            data.active.notfilled[i].author,
            data.active.notfilled[i].requested_by,
            data.active.notfilled[i].ts,
            data.active.notfilled[i].status,
            data.active.notfilled[i].message
	];
	var rowNode = t.row.add( rdata ).draw().node();
	$(rowNode).attr("id",'nf'+data.active.notfilled[i].cid);
	// the :eq selector looks at *visible* nodes....
	$(rowNode).children(":eq(3)").attr("title",data.active.notfilled[i].library);
    }
}
//-----------------------------------------------------------------------------
function format( data ) {
    var sOut;
    var numDetails = data.request_details.length; 
    sOut = '<div class="innerDetails">';
    var hasTracking = data.tracking.length;
    if (hasTracking) {
	sOut += '<div><p>Canada Post tracking number: '+data.tracking[0].tracking+' &nbsp;&nbsp;&nbsp;&nbsp;<a href="http://www.canadapost.ca/cpotools/apps/track/personal/findByTrackNumber?trackingNumber='+data.tracking[0].tracking+'" target="_blank" style="text-decoration:underline;">Open CP tracking site...</a></p></div>';
    }
    
    sOut += '<table id="gradient-style" cellpadding="5" cellspacing="0" border="0" style="padding-left:50px;">'+
	'<thead><th>Request ID</th><th>Timestamp</th><th>Msg from</th><th>Msg to</th><th>Status</th><th>Extra information</th></thead>';
    for (var i = 0; i < numDetails; i++) {
	var detRow = '<tr>'+
	    '<td>'+data.request_details[i].request_id+'</td>'+
	    '<td>'+data.request_details[i].ts+'</td>'+
	    '<td>'+data.request_details[i].from+'</td>'+
	    '<td>'+data.request_details[i].to+'</td>'+
	    '<td>'+data.request_details[i].status+'</td>'+
	    '<td>'+data.request_details[i].message+'</td>'+
	    '</tr>';
	sOut=sOut+detRow;
    }
    sOut = sOut+'</table>'+'</div>';
    var jQ = $($.parseHTML(sOut));
    return jQ;
}

//-----------------------------------------------------------------------------
function override( e, cid, localData, table, row )
{
    $.getJSON('/cgi-bin/override.cgi', {"cid": cid, "override": e.id, "data":localData},
	      function(data){
		  // lending table has different number of columns than borrowing table
		  if ((e.id == "bReturned") || (e.id == "bDueDate")) {
		      if (data.status) { table.cell(row,6).data(data.status).draw(); }
		      if (data.message) { table.cell(row,7).data(data.message).draw(); }
		  } else {
		      if (data.status) { table.cell(row,8).data(data.status).draw(); }
		      if (data.message) { table.cell(row,9).data(data.message).draw(); }
		  }
		  if (data.alert_text) { alert(data.alert_text); };
	      })
	.success(function() {
	})
	.error(function() {
	    alert('error');
	})
	.complete(function() {
	});
}

//-----------------------------------------------------------------------------
function formatBorrowingOverrides( parms ) {
    var sOut = '<div class="innerDetails">'+
	'<table id="overrides-list" cellpadding="5" cellspacing="0" border="0" style="padding-left:50px;">'+
	'<thead><th>Action</th><th>Do this...</th></thead>';

    sOut = sOut+'<tr><td><button id="bReceive" class="override-button">Receive</button></td><td>if you have received the book from the lender, but the lender has not marked it as "Shipped".<br/>An override message will be added to the request, and it will be forced to "Shipped".<br/>The request will be added to your "Receiving" list so that you can control slip printing.</td></tr>';
    sOut = sOut+'<tr><td><button id="bLost" class="override-button">Lost</button></td><td>if your patron or your library has lost the item, or the lender marked it as "Shipped" but you never received it.<br/>When the lender confirms the "Lost" message, the request will be closed and moved to history.</td></tr>';
    sOut = sOut+'<tr><td><button id="bClose" class="override-button">Close</button></td><td>if you have returned the book to the lender, but you get an Overdue notice because the lender has not marked it as "Checked-in"<br/>An override message will be added to the request, and it will be closed and moved to history.</td></tr>';

    sOut = sOut+'</table>'+'</div>';
    var jQ = $($.parseHTML(sOut));
    return jQ;
}


//-----------------------------------------------------------------------------
function formatLendingOverrides( parms ) {
    var sOut = '<div class="innerDetails">'+
	'<table id="overrides-list" cellpadding="5" cellspacing="0" border="0" style="padding-left:50px;">'+
	'<thead><th>Action</th><th>Do this...</th></thead>';

    sOut = sOut+'<tr><td><button id="bReturned" class="override-button">Returned</button></td><td>if you have received the book back from the borrower, but the borrower has not marked it as "Returned"<br/>An override message will be added to the request, and it will be marked as "Checked in to ILS" and moved to history.</td></tr>';
    sOut = sOut+'<tr><td><button id="bDueDate" class="override-button">Change due date</button></td><td>if you have said Shipped, but need to change the due date (and the borrower has not marked it as "Received" yet)<br/></td></tr>';

    sOut = sOut+'</table>'+'</div>';
    var jQ = $($.parseHTML(sOut));
    return jQ;
}

//-----------------------------------------------------------------------------
$(function() {
// Keeping this around so I remember how to build allFields :-)
//    var name = $( "#name" ),
//    email = $( "#email" ),
//    password = $( "#password" ),
//    allFields = $( [] ).add( name ).add( email ).add( password ),
//    tips = $( ".validateTips" );

    var duedate = $( "#duedate" );
    allFields = $( [] ).add( duedate );
    tips = $( ".validateTips" );

    function updateTips( t ) {
	tips
	    .text( t )
	    .addClass( "ui-state-highlight" );
	setTimeout(function() {
	    tips.removeClass( "ui-state-highlight", 1500 );
	}, 500 );
    }

    function checkRegexp( o, regexp, n ) {
	if ( !( regexp.test( o.val() ) ) ) {
	    o.addClass( "ui-state-error" );
	    updateTips( n );
	    return false;
	} else {
	    return true;
	}
    }

    $( "#dialog-form" ).dialog({
	autoOpen: false,
	height: 400,
	width: 400,
	modal: true,
	buttons: [
	    { "text": "Update due date",
	      "class": "override-dialog-button",
	      "click": function() {
		  var bValid = true;
		  allFields.removeClass( "ui-state-error" );
		  bValid = bValid && checkRegexp( duedate, /^([0-9]{4}\-[0-9]{2}\-[0-9]{2})$/, "Due date must be in YYYY-MM-DD format." );
		  if ( bValid ) {
		      var fromButton = $(this).data('fromButton');
		      var cid = $(this).data('cid');
		      var table = $(this).data('table');
		      var row = $(this).data('row');

		      override( fromButton, cid, duedate.val(), table, row );

		      $( this ).dialog( "close" );
		      $('div.innerDetails', row.child()).slideUp( function () {
			  row.child.hide();
			  tr.removeClass('details');
		      });
		  }
	      }
	    },
	    { "text": "Cancel",
	      "class": "override-dialog-button",
	      "click": function() {
		  $( this ).dialog( "close" );
	      }
	    }
	],
	close: function() {
	    allFields.val( "" ).removeClass( "ui-state-error" );
	},
   });

});
