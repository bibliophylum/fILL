// report-folder.js
/*
    fILL - Free/Open-Source Interlibrary Loan management system
    Copyright (C) 2012  Government of Manitoba

    report-folder.js is a part of fILL.

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
    for (var i=0;i<data.reports.completed.length;i++) {
	data.reports.completed[i].actions = ''; // add the 'actions' column
	var ai = oTable_completed.fnAddData( data.reports.completed[i] );
	//alert(data.reports.completed[i].download);
	// make clinks lickable

	var n = oTable_completed.fnSettings().aoData[ ai[0] ].nTr;
	// n is now the TR that was added
	n.setAttribute('id',data.reports.completed[i].rcid);
	$("#"+data.reports.completed[i].rcid+" td:nth-child(5)").html("<a href='?rm=send_report_output&doc="+
								      data.reports.completed[i].download+
								      "'>"+
								      data.reports.completed[i].download+
								      "</a>");

	
	var divActions = document.createElement("div");

	var b1 = document.createElement("input");
	b1.type = "button";
	b1.value = "View";
	b1.onclick = make_view_handler( data.reports.completed[i].rid );
	divActions.appendChild(b1);

	var b2 = document.createElement("input");
	b2.type = "button";
	b2.value = "Delete";
	b2.onclick = make_delete_handler( data.reports.completed[i].rid );
	divActions.appendChild(b2);

	$("#"+data.reports.completed[i].rcid+" td:last-child").append( divActions );
    }

    for (var i=0;i<data.reports.queued.length;i++) {
	data.reports.queued[i].actions = '';
	var ai = oTable_queued.fnAddData( data.reports.queued[i] );

	var divActions = document.createElement("div");
	var b1 = document.createElement("input");
	b1.type = "button";
	b1.value = "Cancel";
//	b1.onclick = make_report_handler( data.reports.queued[i].rid );
	divActions.appendChild(b1);
	$("#datatable_queued tr:last td:last-child").append( divActions );
	$("#datatable_queued tr:last").attr("rid",data.reports.queued[i].rid);
    }

    toggleLayer("waitDiv");
    toggleLayer("tabs");
}

// Explanation of why we need a function to create the buttons' onclick handlers:
// http://www.webdeveloper.com/forum/archive/index.php/t-100584.html
// Short answer: scoping and closures

function make_view_handler( generator ) {
    return function() { view_report( generator ) };
}


//<a href="http://www.example.com/" onclick="javascript:openWindow(this.href);return false;">Click Me</a>


function view_report( rid ) {
    $.getJSON('/cgi-bin/queue-report.cgi', { "oid":   oid,
                                             "rid":   rid,
                                             "start": d_s, 
                                             "end":   d_e
                                           },
              function(data){
		  $("tr[rid="+rid+"] td:last-child div input").remove();
		  $("tr[rid="+rid+"] td:last-child div").append('<p>Queued.</p>');
		  alert('Report has been queued.');
              })
    	.success(function() {
       	})
       	.error(function() {
            alert('error');
       	})
       	.complete(function() {
       	});
}

function make_delete_handler( generator ) {
    return function() { delete_report( generator ) };
}

function delete_report( rid ) {
/*
    $.getJSON('/cgi-bin/queue-report.cgi', { "oid":   oid,
                                             "rid":   rid,
                                             "start": d_s, 
                                             "end":   d_e
                                           },
              function(data){
		  $("tr[rid="+rid+"] td:last-child div input").remove();
		  $("tr[rid="+rid+"] td:last-child div").append('<p>Queued.</p>');
		  alert('Report has been queued.');
              })
    	.success(function() {
       	})
       	.error(function() {
            alert('error');
       	})
       	.complete(function() {
       	});
*/
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
    //alert('toggled ' + whichLayer);
}

function set_primary_tab(tab_id) {
    document.getElementById(tab_id).className='current_tab';
}

function set_secondary_tab(tab_id) {
    document.getElementById(tab_id).className='current_tab';
}

function openWindow( url )
{
  window.open(url, '_blank');
  window.focus();
}

