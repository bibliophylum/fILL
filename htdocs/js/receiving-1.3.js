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

    $.getJSON('/cgi-bin/get-receiving-list.cgi', {oid: $("#oid").text()},
            function(data){
                //alert (data.receiving[0].id+" "+data.receiving[0].msg_from+" "+data.receiving[0].call_number+" "+data.receiving[0].author+" "+data.receiving[0].title+" "+data.receiving[0].ts); //further debug
                build_table(data);

                $('#receiving-table').DataTable({
                       "jQueryUI": true,
                       "pagingType": "full_numbers",
                       "info": true,
                       "ordering": true,
                       "dom": '<"H"Tfr>t<"F"ip>',
                       // TableTools requires Flash version 10...
	               "tableTools": {
                           "sSwfPath": "/plugins/DataTables-1.10.2/extensions/TableTools/swf/copy_csv_xls_pdf.swf",
		           "aButtons": [
			      "copy", "csv", "xls", "pdf", "print",
			      {
				"sExtends":    "collection",
				"sButtonText": "Save",
				"aButtons":    [ "csv", "xls", "pdf" ]
			      }
		           ]
        	       },
                       "columnDefs": [ {
                           "targets": [0,1,2,7],
                           "visible": false
                       } ],
                      "initComplete": function() {
                         // this handles a bug(?) in this version of datatables;
                         // hidden columns caused the table width to be set to 100px, not 100% 
                         $("#receiving-table").css("width","100%");
                      }


                  });
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
//    alert( 'in build_table' );
    var myTable = document.createElement("table");
    myTable.setAttribute("id","receiving-table");
    myTable.className = myTable.className + " row-border";
    var tHead = myTable.createTHead();
    var row = tHead.insertRow(-1);
    var cell;
    // Can't just use:
    // cell = row.insertCell(-1); cell.innerHTML = "ID";
    // ...because insertCell inserts TD elements, and our CSS uses TH for header cells.
    
    cell = document.createElement("TH"); cell.innerHTML = "gid"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "cid"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "ID"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Title"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Author"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Patron"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "From"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "From (ID)"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Last update"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Due date"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Receive"; row.appendChild(cell);
    
    var tFoot = myTable.createTFoot();
    row = tFoot.insertRow(-1);
    cell = row.insertCell(-1); cell.colSpan = "11"; cell.innerHTML = "As items are received, they are removed from this list.  You can see the status of all of your active ILLs in the \"Current ILLs\" screen.";
    
    // explicit creation of TBODY element to make IE happy
    var tBody = document.createElement("TBODY");
    myTable.appendChild(tBody);
    
//    alert('building rows');
    for (var i=0;i<data.receiving.length;i++) 
    {
//	alert (data.receiving[i].id+" "+data.receiving[i].msg_from+" "+data.receiving[i].call_number+" "+data.receiving[i].author+" "+data.receiving[i].title+" "+data.receiving[i].ts); //further debug
        row = tBody.insertRow(-1); row.id = 'req'+data.receiving[i].id;
        cell = row.insertCell(-1); cell.innerHTML = data.receiving[i].gid;
        cell = row.insertCell(-1); cell.innerHTML = data.receiving[i].cid;
        cell = row.insertCell(-1); cell.innerHTML = data.receiving[i].id;
        cell = row.insertCell(-1); cell.innerHTML = data.receiving[i].title;
        cell = row.insertCell(-1); cell.innerHTML = data.receiving[i].author;
        cell = row.insertCell(-1); cell.innerHTML = data.receiving[i].patron_barcode;
        cell = row.insertCell(-1); cell.innerHTML = data.receiving[i].from; cell.setAttribute('title', data.receiving[i].library);
        cell = row.insertCell(-1); cell.innerHTML = data.receiving[i].msg_from;
        cell = row.insertCell(-1); cell.innerHTML = data.receiving[i].ts;
        cell = row.insertCell(-1); cell.innerHTML = data.receiving[i].message;
        cell = row.insertCell(-1); 

	var divResponses = document.createElement("div");
	divResponses.id = 'divResponses'+data.receiving[i].id;

	var b1 = document.createElement("input");
	b1.type = "button";
	b1.value = "Received";
	b1.className = "action-button";
	var requestId = data.receiving[i].id;
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
	
	cell.appendChild( divResponses );
    }
    
    document.getElementById('mylistDiv').appendChild(myTable);
    
    $("#waitDiv").hide();
    $("#mylistDiv").show();
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
			$("#slip").printElement({ leaveOpen:true, printMode:'popup'});
			//		$("#slip").printElement({ leaveOpen:false, printMode:'iframe'});
		    });
		} else {
		    $('<div id="slip"></div>').appendTo("#multiPrint");
		    var urlSlipWriter='/cgi-bin/slip.cgi?reqid='+requestId;
		    $("#slip").load( urlSlipWriter, function() {
			$("#slip").append('<br /><hr class=dotted><br />');
			$("#slip").removeAttr('id');
			
			var para;
			if ($("#multiPrint > div").length == 1) {
			    para='<p class="slipCount">There is 1 slip to be printed.  <input type="button" class="library-style" onclick="printMulti(); return false;" value="Print now"></p>';
			} else {
			    para='<p class="slipCount">There are '+$("#multiPrint > div").length+' slips to be printed.  <input type="button" onclick="printMulti(); return false;" value="Print now"></p>';
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
	    // slideUp doesn't work for <tr>
	    $("#req"+requestId).fadeOut(400, function() { $(this).remove(); }); // toast the row
	});
}

function printMulti() {
    $("#multiPrint").printElement({ leaveOpen:true, printMode:'popup'});
    $("#multiPrint > div").remove();
    $('.slipCount').remove();
}

function make_tracking_handler( tracking ) {
    return function() { window.open("http://www.canadapost.ca/cpotools/apps/track/personal/findByTrackNumber?trackingNumber="+tracking, "_blank"); };
}
