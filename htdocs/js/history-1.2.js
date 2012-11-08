// history.js
/*
    fILL - Free/Open-Source Interlibrary Loan management system
    Copyright (C) 2012  Government of Manitoba

    history.js is a part of fILL.

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
    for (var i=0;i<data.history.borrowing.length;i++) {
	var ai = oTable_borrowing.fnAddData( data.history.borrowing[i], false );
    }
    oTable_borrowing.fnDraw();

    for (var i=0;i<data.history.lending.length;i++) {
	var ai = oTable_lending.fnAddData( data.history.lending[i], false );
    }
    oTable_lending.fnDraw();

    toggleLayer("waitDiv");
    toggleLayer("tabs");
}

function fnFormatDetails( oTable, nTr )
{
    var oData = oTable.fnGetData( nTr );
//    alert('getting details for reqid: '+oData.id);
    $.getJSON('/cgi-bin/get-history-details.cgi', { "cid": oData.cid },
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
	    var numDetails = data.request_history.length; 
	    sOut = '<div class="innerDetails">'+
		'<table id="gradient-style" cellpadding="5" cellspacing="0" border="0" style="padding-left:50px;">'+
		'<thead><th>Request ID</th><th>Timestamp</th><th>Msg from</th><th>Msg to</th><th>Status</th><th>Extra information</th></thead>';
	    for (var i = 0; i < numDetails; i++) {
		var detRow = '<tr>'+
		    '<td>'+data.request_history[i].request_id+'</td>'+
		    '<td>'+data.request_history[i].ts+'</td>'+
		    '<td>'+data.request_history[i].from+'</td>'+
		    '<td>'+data.request_history[i].to+'</td>'+
		    '<td>'+data.request_history[i].status+'</td>'+
		    '<td>'+data.request_history[i].message+'</td>'+
		    '</tr>';
		sOut=sOut+detRow;
	    }
	    sOut = sOut+'</table>'+'</div>';
            var nDetailsRow = oTable.fnOpen( nTr, sOut, 'details' );
            $('div.innerDetails', nDetailsRow).slideDown();

	});
}

function requery( lid ) 
{
    var d_s = moment( $("#startdate").datepicker("getDate") ).format("YYYY-MM-DD");
    var d_e = moment( $("#enddate").datepicker("getDate") ).format("YYYY-MM-DD");
//    alert( d_s+"\n"+d_e );
    toggleLayer("waitDiv");
    toggleLayer("tabs");
    $.getJSON('/cgi-bin/get-history.cgi', { "lid":   lid,
                                            "start": d_s, 
                                            "end":   d_e
                                          },
              function(data){
//		  alert('first success');
		  oTable_borrowing.fnClearTable();
		  oTable_lending.fnClearTable();
//		  alert('data is: '+data.history.borrowing[0].title);
                  build_table(data);
              })
    	.success(function() {
//            alert('success');
       	})
       	.error(function() {
            alert('error');
       	})
       	.complete(function() {
//            alert('ajax complete');
       	});
};


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
    //alert('toggled ' + whichLayer);
}

function set_primary_tab(tab_id) {
    document.getElementById(tab_id).className='current_tab';
}

function set_secondary_tab(tab_id) {
    document.getElementById(tab_id).className='current_tab';
}


