// history.js
function build_table( data ) {
    for (var i=0;i<data.history.borrowing.length;i++) {
	var ai = oTable_borrowing.fnAddData( [
	    data.history.borrowing[i].id,
	    data.history.borrowing[i].title,
	    data.history.borrowing[i].author,
	    data.history.borrowing[i].patron_barcode,
	    data.history.borrowing[i].ts
	] );
//	var n = oTable_borrowing.fnSettings().aoData[ ai[0] ].nTr;
//	n.setAttribute('id', data.history.borrowing[i].id); 
    }


    for (var i=0;i<data.history.lending.length;i++) {
	var ai = oTable_lending.fnAddData( [
	    data.history.lending[i].id,
	    data.history.lending[i].title,
	    data.history.lending[i].author,
	    data.history.lending[i].requester,
	    data.history.lending[i].ts
	] );
//	var n = oTable_borrowing.fnSettings().aoData[ ai[0] ].nTr;
//	n.setAttribute('id', data.history.borrowing[i].id); 
    }
    toggleLayer("waitDiv");
    toggleLayer("mylistDiv");
}

function fnFormatDetails( oTable, nTr )
{
    var oData = oTable.fnGetData( nTr );
    var sOut;
    $.getJSON('/cgi-bin/get-history-details.cgi', { "reqid": oData[0] },
	      function(data){
//		  alert('change request status: '+data+'\n'+parms[0].status);
	      })
	.success(function() {
	    var numDetails = data.request_history.length; 
	    sOut =
		'<div class="innerDetails">'+
		'<table cellpadding="5" cellspacing="0" border="0" style="padding-left:50px;">';
	    for (var i = 0; i < numDetails; i++) {
		sOut=sOut+'<tr><td>'+data.request_history.ts+'</td>'+
		    '<td>'+data.request_history.msg_from+'</td>'+
		    '<td>'+data.request_history.msg_to+'</td>'+
		    '<td>'+data.request_history.status+'</td>'+
		    '<td>'+data.request_history.message+'</td></tr>'
	    }
	    sOut = sOut+'</table>'+'</div>';
	})
	.error(function() {
	    alert('error');
	})
	.complete(function() {
	    // slideUp doesn't work for <tr>
	    $("#req"+requestId).fadeOut(400, function() { $(this).remove(); }); // toast the row
	});

  return sOut;
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


