// active.js
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
            $('div.innerDetails', nDetailsRow).slideDown();

	});
}


function fnFormatBorrowingActions( oTable, nTr )
{
    var oData = oTable.fnGetData( nTr );
    sOut = '<div class="innerDetails">'+
	'<table id="gradient-style" cellpadding="5" cellspacing="0" border="0" style="padding-left:50px;">'+
	'<thead><th>Action</th><th>Do this...</th></thead>';

//    sOut = sOut+'<tr><td><button class="ui-button ui-button-text-only ui-widget ui-state-default ui-corner-all"><span class="ui-button-text">Receive</span></button></td><td>if you have received the book from the lender, but the lender has not marked it as "Shipped"</td></tr>';
//    sOut = sOut+'<tr><td><button class="ui-button ui-button-text-only ui-widget ui-state-default ui-corner-all"><span class="ui-button-text">Close</span></button></td><td>if you have returned the book to the lender, but you get an Overdue notice because the lender has not marked it as "Checked-in"</td></tr>';

    sOut = sOut+'<tr><td><button id="bReceive">Receive</button></td><td>if you have received the book from the lender, but the lender has not marked it as "Shipped"</td></tr>';
    sOut = sOut+'<tr><td><button id="bClose">Close</button></td><td>if you have returned the book to the lender, but you get an Overdue notice because the lender has not marked it as "Checked-in"</td></tr>';

    sOut = sOut+'</table>'+'</div>';
    var nDetailsRow = oTable.fnOpen( nTr, sOut, 'details' );
    $('#bReceive').button();
    $('#bClose').button();
    $('div.innerDetails', nDetailsRow).slideDown();
}


function fnFormatLendingActions( oTable, nTr )
{
    var oData = oTable.fnGetData( nTr );
    sOut = '<div class="innerDetails">'+
	'<table id="gradient-style" cellpadding="5" cellspacing="0" border="0" style="padding-left:50px;">'+
	'<thead><th>Action</th><th>Do this...</th></thead>';

    sOut = sOut+'<tr><td><button id="bReturned">Returned</span></button></td><td>if you have received the book back from the borrower, but the borrower has not marked it as "Returned"</td></tr>';

    sOut = sOut+'</table>'+'</div>';
    var nDetailsRow = oTable.fnOpen( nTr, sOut, 'details' );
    $('#bReturned').button();
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


