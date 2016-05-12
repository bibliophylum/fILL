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
  

    var anOpenBorrowing = [];
    var anOpenLending = [];
    var anOpenNotfilled = [];
    var sImageUrl = "/img/";

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
            //alert('ajax complete');

	    activate_detail_control( $("#datatable_borrowing"), anOpenBorrowing );
	    activate_detail_control( $("#datatable_lending"),   anOpenLending   );
	    activate_detail_control( $("#datatable_notfilled"), anOpenNotfilled );

	    activate_overrides_control( $("#datatable_borrowing"), anOpenBorrowing );
	    activate_overrides_control( $("#datatable_lending"),   anOpenLending   );
	    activate_overrides_control( $("#datatable_notfilled"), anOpenNotfilled );

	});  // end of .complete()
});

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
            var nDetailsRow = oTable.fnOpen( nTr, sOut, 'details' );
	    $(nDetailsRow).attr('detail','conversation');
            $('div.innerDetails', nDetailsRow).slideDown();
	});
}


function override( e, cid, localData, oTable, nTr )
{
//    alert("cid: "+cid+"\noverride: "+e.id+"\ndata: "+localData);
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
    sOut = sOut+'<tr><td><button id="bLost" class="override-button">Lost</button></td><td>if your patron or your library has lost the item, or the lender marked it as "Shipped" but you never received it.<br/>When the lender confirms the "Lost" message, the request will be closed and moved to history.</td></tr>';
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
    $('#bLost').button();
    $('#bLost').click(function() { 
	var borrowerMessage = prompt("Please enter a message for the lender:");
	if (borrowerMessage != null) {
	    override( this, aData[2], borrowerMessage, oTable, nTr );
	}
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
	var sImageUrl = "/img/";

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
	var sImageUrl = "/img/";

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
	height: 400,
	width: 400,
	modal: true,
	buttons: {
	    "Update due date": function() {
		var bValid = true;
		allFields.removeClass( "ui-state-error" );
		bValid = bValid && checkRegexp( duedate, /^([0-9]{4}\-[0-9]{2}\-[0-9]{2})$/, "Due date must be in YYYY-MM-DD format." );
		if ( bValid ) {
		    var fromButton = $(this).data('fromButton');
		    var aData = $(this).data('aData');
		    var oTable = $(this).data('oTable');
		    var nTr = $(this).data('nTr');
		    //alert('fromButton:'+fromButton+'\naData[1]:'+aData[1]+'\nduedate.val():'+duedate.val()+'\noTable:'+oTable+'\nnTr:'+nTr);
		    override( fromButton, aData[1], duedate.val(), oTable, nTr );
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
