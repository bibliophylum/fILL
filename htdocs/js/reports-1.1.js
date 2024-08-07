// reports.js
/*
    fILL - Free/Open-Source Interlibrary Loan management system
    Copyright (C) 2012  Government of Manitoba

    reports.js is a part of fILL.

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
    for (var i=0;i<data.reports.summary.length;i++) {
	data.reports.summary[i].actions = ''; // add the 'actions' column
	var ai = oTable_summary.fnAddData( data.reports.summary[i] );

	var divActions = document.createElement("div");
	var b1 = document.createElement("input");
	b1.type = "button";
	b1.value = "Run report";
	b1.onclick = make_report_handler( data.reports.summary[i].rid );
	divActions.appendChild(b1);
	$("#datatable_summary > tbody > tr > td:first-child:contains("+data.reports.summary[i].rid+")").parent().attr("rid",data.reports.summary[i].rid);
	$('#datatable_summary > tbody > tr[rid="'+data.reports.summary[i].rid+'"] > td:last-child').append( divActions );
    }

    for (var i=0;i<data.reports.borrowing.length;i++) {
	data.reports.borrowing[i].actions = '';
	var ai = oTable_borrowing.fnAddData( data.reports.borrowing[i] );

	var divActions = document.createElement("div");
	var b1 = document.createElement("input");
	b1.type = "button";
	b1.value = "Run report";
	b1.onclick = make_report_handler( data.reports.borrowing[i].rid );
	divActions.appendChild(b1);
	$("#datatable_borrowing > tbody > tr > td:first-child:contains('"+data.reports.borrowing[i].rid+"')").parent().attr("rid",data.reports.borrowing[i].rid);
	$('#datatable_borrowing > tbody > tr[rid="'+data.reports.borrowing[i].rid+'"] > td:last-child').append( divActions );
    }

    for (var i=0;i<data.reports.lending.length;i++) {
	data.reports.lending[i].actions = '';
	var ai = oTable_lending.fnAddData( data.reports.lending[i] );

	var divActions = document.createElement("div");
	var b1 = document.createElement("input");
	b1.type = "button";
	b1.value = "Run report";
	b1.onclick = make_report_handler( data.reports.lending[i].rid );
	divActions.appendChild(b1);
	$("#datatable_lending > tbody > tr > td:first-child:contains("+data.reports.lending[i].rid+")").parent().attr("rid",data.reports.lending[i].rid);
	$('#datatable_lending > tbody > tr[rid="'+data.reports.lending[i].rid+'"] > td:last-child').append( divActions );
    }

    for (var i=0;i<data.reports.narrative.length;i++) {
	data.reports.narrative[i].actions = '';
	var ai = oTable_narrative.fnAddData( data.reports.narrative[i] );

	var divActions = document.createElement("div");
	var b1 = document.createElement("input");
	b1.type = "button";
	b1.value = "Run report";
	b1.onclick = make_report_handler( data.reports.narrative[i].rid );
	divActions.appendChild(b1);
	$("#datatable_narrative > tbody > tr > td:first-child:contains("+data.reports.narrative[i].rid+")").parent().attr("rid",data.reports.narrative[i].rid);
	$('#datatable_narrative > tbody > tr[rid="'+data.reports.narrative[i].rid+'"] > td:last-child').append( divActions );
    }

    toggleLayer("waitDiv");
    toggleLayer("tabs");
}

// Explanation of why we need a function to create the buttons' onclick handlers:
// http://www.webdeveloper.com/forum/archive/index.php/t-100584.html
// Short answer: scoping and closures

function make_report_handler( rid ) {
    return function() { report( rid ) };
}

function report( rid ) {
    var oid=$("#middlecontent").attr("oid");
    var d_s = moment( $("#startdate").datepicker("getDate") ).format("YYYY-MM-DD");
    var d_e = moment( $("#enddate").datepicker("getDate") ).format("YYYY-MM-DD");
    alert('report #'+rid+', library #'+oid+', '+d_s+' to '+d_e);
    
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

function requery( oid ) 
{
    var d_s = moment( $("#startdate").datepicker("getDate") ).format("YYYY-MM-DD");
    var d_e = moment( $("#enddate").datepicker("getDate") ).format("YYYY-MM-DD");
    toggleLayer("waitDiv");
    toggleLayer("tabs");

// As an example, here's how it is in reports.js:
// (but we don't need to query the db to fill the tables here....)
//
//    $.getJSON('/cgi-bin/get-history.cgi', { "oid":   oid,
//                                            "start": d_s, 
//                                            "end":   d_e
//                                          },
//              function(data){
//		  oTable_borrowing.fnClearTable();
//		  oTable_lending.fnClearTable();
//                  build_table(data);
//              })
//    	.success(function() {
//       	})
//       	.error(function() {
//            alert('error');
//       	})
//       	.complete(function() {
//       	});

// these would ordinarily be called from build_table
    toggleLayer("waitDiv");
    toggleLayer("tabs");

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


