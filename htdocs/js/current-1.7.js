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
function build_table_orig( data ) {
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

    $("#waitDiv").hide();
    $("#tabs").show();
}

function build_table( data ) {
    build_table_borrowing( data );
    build_table_lending( data );
    build_table_notfilled( data );
    
    $("#waitDiv").hide();
    $("#tabs").show();
}

function build_table_borrowing( data ) {
    var myTable = document.createElement("table");
    myTable.setAttribute("id","datatable_borrowing");
    myTable.className = myTable.className + " row-border";
    var tHead = myTable.createTHead();
    var row = tHead.insertRow(-1);
    var cell;
    // Can't just use:
    // cell = row.insertCell(-1); cell.innerHTML = "ID";
    // ...because insertCell inserts TD elements, and our CSS uses TH for header cells.
    
    cell = document.createElement("TH"); cell.innerHTML = " "; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "gid"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "cid"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Title"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Author"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Patron barcode"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Lender"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Last update"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Status"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Message"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Overrides"; row.appendChild(cell);
    
    var tFoot = myTable.createTFoot();
    row = tFoot.insertRow(-1);
    cell = row.insertCell(-1); cell.colSpan = "11"; cell.innerHTML = "Items you are currently borrowing from other libraries.";
    
    // explicit creation of TBODY element to make IE happy
    var tBody = document.createElement("TBODY");
    myTable.appendChild(tBody);
    
    for (var i=0;i<data.active.borrowing.length;i++) 
    {
        row = tBody.insertRow(-1); row.id = 'borr'+data.active.borrowing[i].gid+'-'+data.active.borrowing[i].cid;
        cell = row.insertCell(-1); cell.innerHTML = null;
        cell = row.insertCell(-1); cell.innerHTML = data.active.borrowing[i].gid;
        cell = row.insertCell(-1); cell.innerHTML = data.active.borrowing[i].cid;
        cell = row.insertCell(-1); cell.innerHTML = data.active.borrowing[i].title;
        cell = row.insertCell(-1); cell.innerHTML = data.active.borrowing[i].author;
        cell = row.insertCell(-1); cell.innerHTML = data.active.borrowing[i].patron_barcode;
        cell = row.insertCell(-1); cell.innerHTML = data.active.borrowing[i].lender; cell.setAttribute('title', data.active.borrowing[i].library_name);
        cell = row.insertCell(-1); cell.innerHTML = data.active.borrowing[i].ts;
        cell = row.insertCell(-1); cell.innerHTML = data.active.borrowing[i].status;
        cell = row.insertCell(-1); cell.innerHTML = data.active.borrowing[i].message;
        cell = row.insertCell(-1); cell.innerHTML = null;
    }
    
    document.getElementById('tabs-1').appendChild(myTable);
}

function build_table_lending( data ) {
    var myTable = document.createElement("table");
    myTable.setAttribute("id","datatable_lending");
    myTable.className = myTable.className + " row-border";
    var tHead = myTable.createTHead();
    var row = tHead.insertRow(-1);
    var cell;
    // Can't just use:
    // cell = row.insertCell(-1); cell.innerHTML = "ID";
    // ...because insertCell inserts TD elements, and our CSS uses TH for header cells.
    
    cell = document.createElement("TH"); cell.innerHTML = " "; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "cid"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Title"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Author"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Requested by"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Last update"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Status"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Message"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Overrides"; row.appendChild(cell);
    
    var tFoot = myTable.createTFoot();
    row = tFoot.insertRow(-1);
    cell = row.insertCell(-1); cell.colSpan = "9"; cell.innerHTML = "Items you are currently lending to other libraries.";
    
    // explicit creation of TBODY element to make IE happy
    var tBody = document.createElement("TBODY");
    myTable.appendChild(tBody);
    
    for (var i=0;i<data.active.lending.length;i++) 
    {
        row = tBody.insertRow(-1); row.id = 'lend'+data.active.lending[i].cid;
        cell = row.insertCell(-1); cell.innerHTML = null;
        cell = row.insertCell(-1); cell.innerHTML = data.active.lending[i].cid;
        cell = row.insertCell(-1); cell.innerHTML = data.active.lending[i].title;
        cell = row.insertCell(-1); cell.innerHTML = data.active.lending[i].author;
        cell = row.insertCell(-1); cell.innerHTML = data.active.lending[i].requested_by; cell.setAttribute('title', data.active.lending[i].library);
        cell = row.insertCell(-1); cell.innerHTML = data.active.lending[i].ts;
        cell = row.insertCell(-1); cell.innerHTML = data.active.lending[i].status;
        cell = row.insertCell(-1); cell.innerHTML = data.active.lending[i].message;
        cell = row.insertCell(-1); cell.innerHTML = null;
    }
    
    document.getElementById('tabs-2').appendChild(myTable);
}

function build_table_notfilled( data ) {
    var myTable = document.createElement("table");
    myTable.setAttribute("id","datatable_notfilled");
    myTable.className = myTable.className + " row-border";
    var tHead = myTable.createTHead();
    var row = tHead.insertRow(-1);
    var cell;
    // Can't just use:
    // cell = row.insertCell(-1); cell.innerHTML = "ID";
    // ...because insertCell inserts TD elements, and our CSS uses TH for header cells.
    
    cell = document.createElement("TH"); cell.innerHTML = " "; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "cid"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Title"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Author"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Requested by"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Last update"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Status"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Message"; row.appendChild(cell);
    
    var tFoot = myTable.createTFoot();
    row = tFoot.insertRow(-1);
    cell = row.insertCell(-1); cell.colSpan = "8"; cell.innerHTML = "Requested items that you could not lend.";
    
    // explicit creation of TBODY element to make IE happy
    var tBody = document.createElement("TBODY");
    myTable.appendChild(tBody);
    
    for (var i=0;i<data.active.notfilled.length;i++) 
    {
        row = tBody.insertRow(-1); row.id = 'nf'+data.active.notfilled[i].cid;
        cell = row.insertCell(-1); cell.innerHTML = null;
        cell = row.insertCell(-1); cell.innerHTML = data.active.notfilled[i].cid;
        cell = row.insertCell(-1); cell.innerHTML = data.active.notfilled[i].title;
        cell = row.insertCell(-1); cell.innerHTML = data.active.notfilled[i].author;
        cell = row.insertCell(-1); cell.innerHTML = data.active.notfilled[i].requested_by; cell.setAttribute('title', data.active.notfilled[i].library);
        cell = row.insertCell(-1); cell.innerHTML = data.active.notfilled[i].ts;
        cell = row.insertCell(-1); cell.innerHTML = data.active.notfilled[i].status;
        cell = row.insertCell(-1); cell.innerHTML = data.active.notfilled[i].message;
    }
    
    document.getElementById('tabs-3').appendChild(myTable);
}

function fnFormatDetails( $tbl, nTr )
{
    var oTable = $tbl.dataTable();
    var aData = oTable.fnGetData( nTr ); 

    var cid;
    var id = $tbl.attr("id");
    if (id == "datatable_borrowing") {
        cid = aData[2];
    } else if (id == "datatable_lending") {
        cid = aData[1];
    } else if (id == "datatable_notfilled") {
        cid = aData[1];
    }

    $.getJSON('/cgi-bin/get-current-request-details.cgi', { "cid": cid },
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


function override( e, cid, localData, oTable, nTr )
{
//    alert("cid: "+oData.cid+"\noverride: "+e.id+"\ndata: "+localData);
    $.getJSON('/cgi-bin/override.cgi', {"cid": cid, "override": e.id, "data":localData},
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

function fnFormatBorrowingOverrides( $tbl, nTr, anOpen )
{
    var oTable = $tbl.dataTable();
    var aData = oTable.fnGetData( nTr );
    sOut = '<div class="innerDetails">'+
	'<table id="overrides-list" cellpadding="5" cellspacing="0" border="0" style="padding-left:50px;">'+
	'<thead><th>Action</th><th>Do this...</th></thead>';

    sOut = sOut+'<tr><td><button id="bReceive" class="override-button">Receive</button></td><td>if you have received the book from the lender, but the lender has not marked it as "Shipped".<br/>An override message will be added to the request, and it will be forced to "Shipped".<br/>The request will be added to your "Receiving" list so that you can control slip printing.</td></tr>';
    sOut = sOut+'<tr><td><button id="bTryNextLender" class="override-button">Try next lender</button></td><td>if you have requested a book, but have not received a response from the (potential)<br/>lender in a timely fashion.  This request will be cancelled, and the next lender will be tried.</td></tr>';
    sOut = sOut+'<tr><td><button id="bNoFurtherSources" class="override-button">No further sources</button></td><td>if there are no further sources for you to try.<br/>An override message will be added to the request, and it will be closed and moved to history.</td></tr>';
    sOut = sOut+'<tr><td><button id="bCancel" class="override-button">Cancel</button></td><td>if the lender has not yet responded to your request.<br/>An override message will be added to the request, and it will be closed and moved to history.</td></tr>';
    sOut = sOut+'<tr><td><button id="bClose" class="override-button">Close</button></td><td>if you have returned the book to the lender, but you get an Overdue notice because the lender has not marked it as "Checked-in"<br/>An override message will be added to the request, and it will be closed and moved to history.</td></tr>';

    sOut = sOut+'</table>'+'</div>';
    var nDetailsRow = oTable.fnOpen( nTr, sOut, 'details' );
    $(nDetailsRow).attr('detail','overrides');

    // remove jquery-ui formatting of buttons
    // DOESN'T WORK... button colours are wrong :-(
//    $("#overrides-list :button").removeClass();
//    $("#overrides-list :button").addClass("library-style override-button");
    //$("#overrides-list :button").css('background', "transparent");
//    $("#overrides-list :button").css('background-image', "none");


    $('#bReceive').button();
    $('#bReceive').click(function() { 
	var hasConfirmed = confirm("Overrides are a last resort.\n\nIf you have tried to contact the lender but had no response, click 'Ok' to force this action.\n\nOtherwise, please click 'Cancel', contact them, and ask them to mark the request as 'Shipped'.");
	if (hasConfirmed == true) {
	    override( this, aData[2], null, oTable, nTr );
	}
	return false; 
    });
    $('#bTryNextLender').button();
    $('#bTryNextLender').click(function() { 
	override( this, aData[2], null, oTable, nTr );
	return false; 
    });
    $('#bNoFurtherSources').button();
    $('#bNoFurtherSources').click(function() { 
	override( this, aData[2], null, oTable, nTr );
	return false; 
    });
    $('#bCancel').button();
    $('#bCancel').click(function() { 
	override( this, aData[2], null, oTable, nTr );
	return false; 
    });
    $('#bClose').button();
    $('#bClose').click(function() { 
	var hasConfirmed = confirm("Overrides are a last resort.\n\nIf you have tried to contact the lender but had no response, click 'Ok' to force this action.\n\nOtherwise, please click 'Cancel', contact them, and ask them to mark the request as 'Checked-in'.");
	if (hasConfirmed == true) {
	    override( this, aData[2], null, oTable, nTr );
	    oTable.fnDeleteRow( nTr );
	}
	return false; 
    });
    $('div.innerDetails', nDetailsRow).slideDown();
}


function fnFormatLendingOverrides( $tbl, nTr, anOpen )
{
    var oTable = $tbl.dataTable();
    var aData = oTable.fnGetData( nTr );
    sOut = '<div class="innerDetails">'+
	'<table id="overrides-list" cellpadding="5" cellspacing="0" border="0" style="padding-left:50px;">'+
	'<thead><th>Action</th><th>Do this...</th></thead>';

    sOut = sOut+'<tr><td><button id="bReturned" class="override-button">Returned</button></td><td>if you have received the book back from the borrower, but the borrower has not marked it as "Returned"<br/>An override message will be added to the request, and it will be marked as "Checked in to ILS" and moved to history.</td></tr>';
    sOut = sOut+'<tr><td><button id="bDueDate" class="override-button">Change due date</button></td><td>if you have said Shipped, but need to change the due date (and the borrower has not marked it as "Received" yet)<br/></td></tr>';

    sOut = sOut+'</table>'+'</div>';
    var nDetailsRow = oTable.fnOpen( nTr, sOut, 'details overrideRow' );
    $(nDetailsRow).attr('detail','overrides');

    $('#bReturned').button();
    $('#bReturned').click(function() { 
	var hasConfirmed = confirm("Overrides are a last resort.\n\nIf you have tried to contact the borrower but had no response, click 'Ok' to force this action.\n\nOtherwise, please click 'Cancel', contact them, and ask them to mark the request as 'Returned'.");
	if (hasConfirmed == true) {
	    override( this, aData[1], null, oTable, nTr );
//	    oTable.fnDeleteRow( nTr );
	}
	return false; 
    });

    $("#bDueDate")
	.button()
	.click(function() {
	    $( "#dialog-form" )
		.data('fromButton',this)
		.data('aData',aData)
		.data('oTable',oTable)
		.data('nTr',nTr)
		.dialog( "open" );
	});

    $('div.innerDetails', nDetailsRow).slideDown();
}

function activate_detail_control( $tbl, anOpen ) {

    $tbl.on("click", "td.control", function() {
      var nTr = this.parentNode;
      var i = $.inArray( nTr, anOpen );
//      var sImageUrl = "/plugins/DataTables-1.8.2/examples/examples_support/";
	var sImageUrl = "/plugins/DataTables-1.10.2/examples/resources/";

      if (i === -1) {
        $('img', this).attr( 'src', sImageUrl+"details_close.png" );
	fnFormatDetails($tbl, nTr);
        anOpen.push( nTr );
      }
      else {

	// If we're here, there is either a 'conversation' tr or an 'overrides' tr open
        var rOpen = $(nTr).next('[detail*="conversation"]');
	if (rOpen.length == 0) {
          // must be overrides that is open.  close it and open the conversation
	  $(nTr).children('.overrides').children('img').attr( 'src', sImageUrl+"details_open.png" );
          $('div.innerDetails', $(nTr).next()[0]).slideUp( function () {
            $tbl.fnClose( nTr );
            anOpen.splice( i, 1 );

   	    $(nTr).children('.control').children('img').attr( 'src', sImageUrl+"details_close.png" );
            fnFormatDetails($tbl, nTr);
            anOpen.push( nTr );
          } );
          
	} else {
          // conversation is open, user is closing it.
          $('img', this).attr( 'src', sImageUrl+"details_open.png" );
          $('div.innerDetails', $(nTr).next()[0]).slideUp( function () {
            $tbl.fnClose( nTr );
            anOpen.splice( i, 1 );
          } );
        }
      }
    } );
}

function activate_overrides_control( $tbl, anOpen ) {

    $tbl.on("click", "td.overrides", function() {           // reduce bubble-up
	var nTr = this.parentNode;
	var i = $.inArray( nTr, anOpen );
//	var sImageUrl = "/plugins/DataTables-1.8.2/examples/examples_support/";
	var sImageUrl = "/plugins/DataTables-1.10.2/examples/resources/";

	if ( i === -1 ) {
            $('img', this).attr( 'src', sImageUrl+"details_close.png" );
            var id = $tbl.attr("id");
            if (id == "datatable_borrowing") {
		fnFormatBorrowingOverrides($tbl, nTr, anOpen);
            } else if (id == "datatable_lending") {
		fnFormatLendingOverrides($tbl, nTr, anOpen);
            }
            anOpen.push( nTr );
	}
	else {
	    
            // If we're here, there is either a 'conversation' tr or an 'overrides' tr open
            var rOpen = $(nTr).next('[detail*="overrides"]');
            if (rOpen.length == 0) {
		// must be conversation that is open.  close it and open the overrides
		$(nTr).children('.control').children('img').attr( 'src', sImageUrl+"details_open.png" );
		$('div.innerDetails', $(nTr).next()[0]).slideUp( function () {
		    $tbl.fnClose( nTr );
		    anOpen.splice( i, 1 );
		    
		    $(nTr).children('.overrides').children('img').attr( 'src', sImageUrl+"details_close.png" );
		    var id = $tbl.attr("id");
		    if (id == "datatable_borrowing") {
			fnFormatBorrowingOverrides($tbl, nTr, anOpen);
		    } else if (id == "datatable_lending") {
			fnFormatLendingOverrides($tbl, nTr, anOpen);
		    }
		    anOpen.push( nTr );
		} );
		
            } else {
		// overrides is open, user is closing it.
		$('img', this).attr( 'src', sImageUrl+"details_open.png" );
		$('div.innerDetails', $(nTr).next()[0]).slideUp( function () {
		    $tbl.fnClose( nTr );
		    anOpen.splice( i, 1 );
		} );
            }
	}
    });
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
