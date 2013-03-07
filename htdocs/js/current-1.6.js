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
function build_table( data ) {
    for (var i=0;i<data.active.borrowing.length;i++) {
	var ai = oTable_borrowing.fnAddData( data.active.borrowing[i], false );
    }
    oTable_borrowing.fnDraw();

    for (var i=0;i<data.active.lending.length;i++) {
	var ai = oTable_lending.fnAddData( data.active.lending[i], false );
    }
    oTable_lending.fnDraw();

    for (var i=0;i<data.active.notfilled.length;i++) {
	var ai = oTable_notfilled.fnAddData( data.active.notfilled[i], false );
    }
    oTable_notfilled.fnDraw();

    toggleLayer("waitDiv");
    toggleLayer("tabs");
}

function fnFormatDetails( oTable, nTr )
{
    var oData = oTable.fnGetData( nTr );
    $.getJSON('/cgi-bin/get-current-request-details.cgi', { "cid": oData.cid },
	      function(data){
		  //alert('first success');
	      })
	.success(function() {
	    //alert('success');
	})
	.error(function() {
	    alert('error');
	})
	.complete(function(jqXHRObject) {
	    var data = $.parseJSON(jqXHRObject.responseText)
	    var sOut;
	    var numDetails = data.request_details.length; 
	    sOut = '<div class="innerDetails">'+
		'<table id="gradient-style" cellpadding="5" cellspacing="0" border="0" style="padding-left:50px;">'+
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
            var nDetailsRow = oTable.fnOpen( nTr, sOut, 'details' );
	    $(nDetailsRow).attr('detail','conversation');
            $('div.innerDetails', nDetailsRow).slideDown();

	});
}


function override( e, oData, localData, oTable, nTr )
{
//    alert("cid: "+oData.cid+"\noverride: "+e.id+"\ndata: "+localData);
    $.getJSON('/cgi-bin/override.cgi', {"cid": oData.cid, "override": e.id, "data":localData},
	      function(data){
		  $(nTr).children('.overrides').click();
		  // lending table has different number of columns than borrowing table
		  if ((e.id == "bReturned") || (e.id == "bDueDate")) {
		      if (data.status) { oTable.fnUpdate( data.status, nTr, 6 ); };
		      if (data.message) { oTable.fnUpdate( data.message, nTr, 7 ); };
		  } else {
		      if (data.status) { oTable.fnUpdate( data.status, nTr, 8 ); };
		      if (data.message) { oTable.fnUpdate( data.message, nTr, 9 ); };
		  }
		  if (data.alert_text) { alert(data.alert_text); };
//		  if (data.success) { oTable.fnDeleteRow( nTr ); };
	      })
	.success(function() {
//	    alert('success');
	})
	.error(function() {
	    alert('error');
	})
	.complete(function() {
	    // slideUp doesn't work for <tr>
//	    $("#req"+oData.id).fadeOut(400, function() { $(e).remove(); }); // toast the row
	});
}

function fnFormatBorrowingOverrides( oTable, nTr, anOpen )
{
    var oData = oTable.fnGetData( nTr );
    sOut = '<div class="innerDetails">'+
	'<table id="gradient-style" cellpadding="5" cellspacing="0" border="0" style="padding-left:50px;">'+
	'<thead><th>Action</th><th>Do this...</th></thead>';

    sOut = sOut+'<tr><td><button id="bReceive">Receive</button></td><td>if you have received the book from the lender, but the lender has not marked it as "Shipped".<br/>An override message will be added to the request, and it will be forced to "Shipped".<br/>The request will be added to your "Receiving" list so that you can control slip printing.</td></tr>';
    sOut = sOut+'<tr><td><button id="bTryNextLender">Try next lender</button></td><td>if you have requested a book, but have not received a response from the (potential)<br/>lender in a timely fashion.  This request will be cancelled, and the next lender will be tried.</td></tr>';
    sOut = sOut+'<tr><td><button id="bNoFurtherSources">No further sources</button></td><td>if there are no furher sources for you to try.<br/>This request will be closed and moved to history.</td></tr>';
    sOut = sOut+'<tr><td><button id="bCancel">Cancel</button></td><td>if the lender has not yet responded to your request, you can cancel the request.<br/>An override message will be added to the request, and it will be closed and moved to history.</td></tr>';
    sOut = sOut+'<tr><td><button id="bClose">Close</button></td><td>if you have returned the book to the lender, but you get an Overdue notice because the lender has not marked it as "Checked-in"<br/>An override message will be added to the request, and it will be closed and moved to history.</td></tr>';

    sOut = sOut+'</table>'+'</div>';
    var nDetailsRow = oTable.fnOpen( nTr, sOut, 'details' );
    $(nDetailsRow).attr('detail','overrides');
    $('#bReceive').button();
    $('#bReceive').click(function() { 
	var hasConfirmed = confirm("Overrides are a last resort.\n\nIf you have tried to contact the lender but had no response, click 'Ok' to force this action.\n\nOtherwise, please click 'Cancel', contact them, and ask them to mark the request as 'Shipped'.");
	if (hasConfirmed == true) {
	    override( this, oData, null, oTable, nTr );
	}
	return false; 
    });
    $('#bTryNextLender').button();
    $('#bTryNextLender').click(function() { 
	override( this, oData, null, oTable, nTr );
	return false; 
    });
    $('#bNoFurtherSources').button();
    $('#bNoFurtherSources').click(function() { 
	override( this, oData, null, oTable, nTr );
	return false; 
    });
    $('#bCancel').button();
    $('#bCancel').click(function() { 
	override( this, oData, null, oTable, nTr );
	return false; 
    });
    $('#bClose').button();
    $('#bClose').click(function() { 
	var hasConfirmed = confirm("Overrides are a last resort.\n\nIf you have tried to contact the lender but had no response, click 'Ok' to force this action.\n\nOtherwise, please click 'Cancel', contact them, and ask them to mark the request as 'Checked-in'.");
	if (hasConfirmed == true) {
	    override( this, oData, null, oTable, nTr );
	    oTable.fnDeleteRow( nTr );
	}
	return false; 
    });
    $('div.innerDetails', nDetailsRow).slideDown();
}


function fnFormatLendingOverrides( oTable, nTr, anOpen )
{
    var oData = oTable.fnGetData( nTr );
    sOut = '<div class="innerDetails">'+
	'<table id="gradient-style" cellpadding="5" cellspacing="0" border="0" style="padding-left:50px;">'+
	'<thead><th>Action</th><th>Do this...</th></thead>';

    sOut = sOut+'<tr><td><button id="bReturned">Returned</button></td><td>if you have received the book back from the borrower, but the borrower has not marked it as "Returned"<br/>An override message will be added to the request, and it will be marked as "Checked-in" and moved to history.</td></tr>';
    sOut = sOut+'<tr><td><button id="bDueDate">Change due date</button></td><td>if you have said Shipped, but need to change the due date (and the borrower has not marked it as "Received" yet)<br/></td></tr>';

    sOut = sOut+'</table>'+'</div>';
    var nDetailsRow = oTable.fnOpen( nTr, sOut, 'details overrideRow' );
    $(nDetailsRow).attr('detail','overrides');

    $('#bReturned').button();
    $('#bReturned').click(function() { 
	var hasConfirmed = confirm("Overrides are a last resort.\n\nIf you have tried to contact the borrower but had no response, click 'Ok' to force this action.\n\nOtherwise, please click 'Cancel', contact them, and ask them to mark the request as 'Returned'.");
	if (hasConfirmed == true) {
	    override( this, oData, null, oTable, nTr );
//	    oTable.fnDeleteRow( nTr );
	}
	return false; 
    });

    $("#bDueDate")
	.button()
	.click(function() {
	    $( "#dialog-form" )
		.data('fromButton',this)
		.data('oData',oData)
		.data('oTable',oTable)
		.data('nTr',nTr)
		.dialog( "open" );
	});

    $('div.innerDetails', nDetailsRow).slideDown();
}


function toggleLayer( whichLayer )
{
    var elem, vis;
    if( document.getElementById ) // this is the way the standards work
	elem = document.getElementById( whichLayer );
    else if( document.all ) // this is the way old msie versions work
	elem = document.all[whichLayer];
    else if( document.layers ) // this is the way nn4 works
	elem = document.layers[whichLayer];

    vis = elem.style;
    // if the style.display value is blank we try to figure it out here
    if(vis.display==''&&elem.offsetWidth!=undefined&&elem.offsetHeight!=undefined)
	vis.display = (elem.offsetWidth!=0&&elem.offsetHeight!=0)?'block':'none';
    vis.display = (vis.display==''||vis.display=='block')?'none':'block';
}

function set_primary_tab(tab_id) {
    document.getElementById(tab_id).className='current_tab';
}

function set_secondary_tab(tab_id) {
    document.getElementById(tab_id).className='current_tab';
}

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
	height: 300,
	width: 350,
	modal: true,
	buttons: {
	    "Update due date": function() {
		var bValid = true;
		allFields.removeClass( "ui-state-error" );
		bValid = bValid && checkRegexp( duedate, /^([0-9]{4}\-[0-9]{2}\-[0-9]{2})$/, "Due date must be in YYYY-MM-DD format." );
		if ( bValid ) {
		    var fromButton = $(this).data('fromButton');
		    var oData = $(this).data('oData');
		    var oTable = $(this).data('oTable');
		    var nTr = $(this).data('nTr');
		    override( fromButton, oData, duedate.val(), oTable, nTr );
		    $( this ).dialog( "close" );
		}
	    },
	    Cancel: function() {
		$( this ).dialog( "close" );
	    }
	},
	close: function() {
	    allFields.val( "" ).removeClass( "ui-state-error" );
	}
    });

});