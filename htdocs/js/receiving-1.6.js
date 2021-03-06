// receiving.js
/*
    fILL - Free/Open-Source Interlibrary Loan management system
    Copyright (C) 2012  Government of Manitoba

    receiving.js is a part of fILL.

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
//    $(".btnPrint").printPage();

    $('#receiving-table').DataTable({
        "jQueryUI": true,
        "pagingType": "full_numbers",
        "info": true,
        "ordering": true,
        "dom": '<"H"Bfr>t<"F"ip>',
	buttons: [ 'copy', 'excel', 'pdf', 'print' ],
        "columnDefs": [ {
            "targets": [0,1,2,7],
            "visible": false
        } ],
        "initComplete": function() {
            // this handles a bug(?) in this version of datatables;
            // hidden columns caused the table width to be set to 100px, not 100% 
            $("#receiving-table").css("width","100%");

	    $("#receiving-table").DataTable().page.len( parseInt($("#table_rows_per_page").text(),10));
        }
	
    });

    $.getJSON('/cgi-bin/get-receiving-list.cgi', {oid: $("#oid").text()},
              function(data){
                  build_table(data);
		  $("#waitDiv").hide();
		  $("#mylistDiv").show();
              })
	.success(function() {
        })
	.error(function() {
        })
	.complete(function() { 
        });

    $(function() {
        $( "#datepicker" ).datepicker({ dateFormat: 'yy-mm-dd' });
    });

    $("#slipPrinting").buttonset();
    $("#slipPrinting").append("<input type='radio' name='slip' value='single' id='single' checked='checked'/><label for='single'>Individual slips</label>");
    $("#slipPrinting").append("<input type='radio' name='slip' value='multi' id='multi'/><label for='multi'>Multiple slips on a page</label>");
    $("#slipPrinting").append("<input type='radio' name='slip' value='none' id='none'/><label for='none'>Do not print slips</label>");
    $("#slipPrinting").buttonset('refresh');

    $(function() {
        update_menu_counters( $("#oid").text() );
    });

});

function build_table( data ) {
    var t = $('#receiving-table').DataTable();
    
    for (var i=0;i<data.receiving.length;i++) {

	var divResponses = create_action_buttons( data, i );

	// this should match the fields in the template
	var rdata = [
            data.receiving[i].gid,
            data.receiving[i].cid,
            data.receiving[i].id,
            data.receiving[i].title,
            data.receiving[i].author,
            data.receiving[i].patron_barcode,
            data.receiving[i].from,
            data.receiving[i].msg_from,
            data.receiving[i].ts,
            data.receiving[i].message,
	    ""
	];
	var rowNode = t.row.add( rdata ).draw().node();
	$(rowNode).attr("id",'req'+data.receiving[i].id);
	// the :eq selector looks at *visible* nodes....
	$(rowNode).children(":eq(3)").attr("title",data.receiving[i].library);
	if (data.receiving[i].opt_in == false) { // have not opted in for ILL
	    $(rowNode).children(":eq(3)").addClass("ill-status-no");
	    $(rowNode).children(":eq(3)").attr("title",data.receiving[i].library+" is not open for ILL");
	}

	$(rowNode).children(":last").append( divResponses );

	borrowerNotes_insertChild( t, rowNode,
				   data.receiving[i].borrower_internal_note,
				   "datatable-detail"
				 );
    }
    borrowerNotes_makeEditable();
}

function create_action_buttons( data, i ) {
    var divResponses = document.createElement("div");
    var requestId = data.receiving[i].id;
    divResponses.id = 'divResponses'+requestId;

    var b1 = document.createElement("input");
    b1.type = "button";
    b1.value = "Received";
    b1.className = "action-button";
    b1.onclick = make_receiving_handler( requestId );
    divResponses.appendChild(b1);
    
    if (data.receiving[i].tracking) {
	var $tracking = $('<input/>', 
			  {
			      'type':'button', 
			      'value':'CP tracking', 
			      'class':'action-button',
			      'click': make_tracking_handler( data.receiving[i].tracking )
			  });
	divResponses.appendChild( $tracking[0] );
    }
    
    return divResponses;
}

// Explanation of why we need a function to create the buttons' onclick handlers:
// http://www.webdeveloper.com/forum/archive/index.php/t-100584.html
// Short answer: scoping and closures

function make_receiving_handler( requestId ) {
    return function() { receive( requestId ) };
}

function receive( requestId ) {
    var myRow=$("#req"+requestId);
    var nTr = myRow[0]; // convert jQuery object to DOM
    var oTable = $('#receiving-table').dataTable();
    var aPos = oTable.fnGetPosition( nTr );
    var msg_to = oTable.fnGetData( aPos )[7]; // 8th column (0-based!), hidden or not

    var parms = {
	"reqid": requestId,
	"msg_to": msg_to,
	"oid": $("#oid").text(),
	"status": "Received",
	"message": ""
    };
    $.getJSON('/cgi-bin/change-request-status.cgi', parms,
	      function(data){
//		  alert('change request status: '+data+'\n'+parms[0].status);
	      })
	.success(function() {
	    // print slip (single) / add to slip page (multi) / do nothing (none)

	    if ((!$('input[name=slip]:checked').val()) || ($('input[name=slip]:checked').val() == 'none')) {
		// do not print slips
	    } else {
		if ($('input[name=slip]:checked').val() == 'single') {
		    $("#slip").remove();  // toast any existing slip div
		    $('<div id="slip"></div>').appendTo("#slipbox");
		    $("#slip").css( {"background-color": "white",
				     "border-color": "#C1E0FF", 
				     "border-width":"1px", 
				     "border-style":"solid",
		    });
		    var urlSlipWriter='/cgi-bin/slip.cgi?reqid='+requestId;
		    $("#slip").load( urlSlipWriter, function() {
			$("#slip").printThis({
/*
			    debug: false,
			    importCSS: true,
			    importStyle: false,
			    printContainer: true,
			    pageTitle: "",
			    removeInline: false,
			    printDelay: 333,
			    header: null,
			    formValues: true
*/
			});
		    });
		} else {
		    $('<div id="slip"></div>').appendTo("#multiPrint");
		    var urlSlipWriter='/cgi-bin/slip.cgi?reqid='+requestId;
		    $("#slip").load( urlSlipWriter, function() {
			$("#slip").append('<br /><hr class=dotted><br />');
			$("#slip").removeAttr('id');
			
			var para;
			if ($("#multiPrint > div").length == 1) {
			    para='<p class="slipCount">There is 1 slip to be printed.  <input type="button" class="library-style" onclick="printMulti(); return false;" value="Print now"> <input type="button" onclick="clearMulti(); return false;" value="Clear the print list"></p>';
			} else {
			    para='<p class="slipCount">There are '+$("#multiPrint > div").length+' slips to be printed.  <input type="button" onclick="printMulti(); return false;" value="Print now"> <input type="button" onclick="clearMulti(); return false;" value="Clear the print list"></p>';
			}
			$('.slipCount').remove();
			$("#multiCount").append(para);
		    });
		    
		}
	    }

	})
	.error(function() {
	    alert('error');
	})
	.complete(function() {
	    // toast any child nodes (eg borrower internal notes)
	    var t = $("#receiving-table").DataTable();
	    t.row("#req"+requestId).child.remove();
	    // slideUp doesn't work for <tr>
	    $("#req"+requestId).fadeOut(400, function() { $(this).remove(); }); // toast the row
	});
}

function printMulti() {
    $("#multiPrint").printThis({
/*
	debug: false,
	importCSS: true,
	importStyle: false,
	printContainer: true,
	pageTitle: "",
	removeInline: false,
	printDelay: 333,
	header: null,
	formValues: true
*/
    });
    // There is a delay (and some user interaction required) in printing...
    // the following lines were toasting the print div before printing happened.
    // They are now separated out into the clearMulti() function.
    //    $("#multiPrint > div").remove();
    //    $('.slipCount').remove();
}

function clearMulti() {
    $("#multiPrint > div").remove();
    $('.slipCount').remove();
}

function make_tracking_handler( tracking ) {
    return function() { window.open("http://www.canadapost.ca/cpotools/apps/track/personal/findByTrackNumber?trackingNumber="+tracking, "_blank"); };
}
