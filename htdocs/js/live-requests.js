// live-requests.js
/*
    fILL - Free/Open-Source Interlibrary Loan management system
    Copyright (C) 2012  David A. Christensen

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
function build_table( data ) {
    for (var i=0;i<data.active.borrowing.length;i++) {
	var ai = oTable_borrowing.fnAddData( data.active.borrowing[i] );
    }

    for (var i=0;i<data.active.lending.length;i++) {
	var ai = oTable_lending.fnAddData( data.active.lending[i] );
    }
    toggleLayer("waitDiv");
    toggleLayer("tabs");
}

function fnFormatDetails( oTable, nTr )
{
    var oData = oTable.fnGetData( nTr );
//    alert('getting details for reqid: '+oData.id);
    $.getJSON('/cgi-bin/get-live-request-details.cgi', { "reqid": oData.id },
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
//	    alert('jqHXRObject response text: '+jqXHRObject.responseText);
	    var data = $.parseJSON(jqXHRObject.responseText)
	    var sOut;
	    var numDetails = data.request_details.length; 
	    sOut = '<div class="innerDetails">'+
		'<table id="gradient-style" cellpadding="5" cellspacing="0" border="0" style="padding-left:50px;">'+
		'<thead><th>Timestamp</th><th>Msg from</th><th>Msg to</th><th>Status</th><th>Extra information</th></thead>';
	    for (var i = 0; i < numDetails; i++) {
		var detRow = '<tr><td>'+data.request_details[i].ts+'</td>'+
		    '<td>'+data.request_details[i].from+'</td>'+
//		    '<td>'+data.request_details[i].msg_from+'</td>'+
		    '<td>'+data.request_details[i].to+'</td>'+
//		    '<td>'+data.request_details[i].msg_to+'</td>'+
		    '<td>'+data.request_details[i].status+'</td>'+
		    '<td>'+data.request_details[i].message+'</td></tr>';
		sOut=sOut+detRow;
	    }
	    sOut = sOut+'</table>'+'</div>';
            var nDetailsRow = oTable.fnOpen( nTr, sOut, 'details' );
	    $(nDetailsRow).attr('detail','conversation');
            $('div.innerDetails', nDetailsRow).slideDown();

	});
}


function override( e, oData )
{
//    alert('button: ' + e.id + '\nid: ' + oData.id);
    $.getJSON('/cgi-bin/override.cgi', {"reqid": oData.id, "override": e.id},
	      function(data){
		  //alert(data);
	      })
	.success(function() {
	    //alert('success');
	})
	.error(function() {
	    alert('error');
	})
	.complete(function() {
	    // slideUp doesn't work for <tr>
	    $("#req"+oData.id).fadeOut(400, function() { $(this).remove(); }); // toast the row
	});
}

function fnFormatBorrowingOverrides( oTable, nTr )
{
    var oData = oTable.fnGetData( nTr );
    sOut = '<div class="innerDetails">'+
	'<table id="gradient-style" cellpadding="5" cellspacing="0" border="0" style="padding-left:50px;">'+
	'<thead><th>Action</th><th>Do this...</th></thead>';

    sOut = sOut+'<tr><td><button id="bReceive">Receive</button></td><td>if you have received the book from the lender, but the lender has not marked it as "Shipped".<br/>An override message will be added to the request, and it will be forced to "Shipped".<br/>The request will be added to your "Receiving" list so that you can control slip printing.</td></tr>';
    sOut = sOut+'<tr><td><button id="bClose">Close</button></td><td>if you have returned the book to the lender, but you get an Overdue notice because the lender has not marked it as "Checked-in"<br/>An override message will be added to the request, and it will be closed and moved to history.</td></tr>';

    sOut = sOut+'</table>'+'</div>';
    var nDetailsRow = oTable.fnOpen( nTr, sOut, 'details' );
    $(nDetailsRow).attr('detail','overrides');
    $('#bReceive').button();
    $('#bReceive').click(function() { override( this, oData ); return false; });
    $('#bClose').button();
    $('#bClose').click(function() { override( this, oData ); return false; });
    $('div.innerDetails', nDetailsRow).slideDown();
}


function fnFormatLendingOverrides( oTable, nTr )
{
    var oData = oTable.fnGetData( nTr );
    sOut = '<div class="innerDetails">'+
	'<table id="gradient-style" cellpadding="5" cellspacing="0" border="0" style="padding-left:50px;">'+
	'<thead><th>Action</th><th>Do this...</th></thead>';

    sOut = sOut+'<tr><td><button id="bReturned">Returned</span></button></td><td>if you have received the book back from the borrower, but the borrower has not marked it as "Returned"<br/>An override message will be added to the request, and it will be marked as "Checked-in" and moved to history.</td></tr>';

    sOut = sOut+'</table>'+'</div>';
    var nDetailsRow = oTable.fnOpen( nTr, sOut, 'details overrideRow' );
    $(nDetailsRow).attr('detail','overrides');
    $('#bReturned').button();
    $('#bReturned').click(function() { override( this, oData ); return false; });
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
    //    alert('toggled ' + whichLayer);
}

function set_primary_tab(tab_id) {
    document.getElementById(tab_id).className='current_tab';
}

function set_secondary_tab(tab_id) {
    document.getElementById(tab_id).className='current_tab';
}


