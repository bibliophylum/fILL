// unfilled.js
/*
    fILL - Free/Open-Source Interlibrary Loan management system
    Copyright (C) 2012  Government of Manitoba

    unfilled.js is a part of fILL.

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

    $.getJSON('/cgi-bin/get-unfilled-list.cgi', {oid: $("#oid").text()},
            function(data){
                //alert (data.unfilled[0].id+" "+data.unfilled[0].title+" "+data.unfilled[0].author+" "+data.unfilled[0].patron_barcode+" "+data.unfilled[0].ts); //further debug
                build_table(data); 

                $('#unfilled-table').DataTable({
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
                           "targets": [0,1,2],
                           "visible": false
                       },
                       ],
                      "initComplete": function(settings, json) {
                         // this handles a bug(?) in this version of datatables;
                         // hidden columns caused the table width to be set to 100px, not 100% 
                         $("#unfilled-table").css("width","100%");

	                 while( checkOverflow( $("#myListDiv")[0] ) ) {
                           decreaseTableFontSize();
                         }
                      }

                  });
            });

    $(function() {
           $( "#datepicker" ).datepicker({ dateFormat: 'yy-mm-dd' });
    });

    $(function() {
           update_menu_counters( $("#oid").text() );
    });

});

function build_table( data ) {
    var myTable = document.createElement("table");
    myTable.setAttribute("id","unfilled-table");
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
    cell = document.createElement("TH"); cell.innerHTML = "Patron / Group"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Last update"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "From"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Status"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Message"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Pub date"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Trying source"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Next lender?"; row.appendChild(cell);
    
    var tFoot = myTable.createTFoot();
    row = tFoot.insertRow(-1);
    cell = row.insertCell(-1); cell.colSpan = "13"; cell.innerHTML = "If there are more lenders to try, you can click 'Try next lender'.  You can see the status of all of your active ILLs in the \"Current ILLs\" screen.";
    
    // explicit creation of TBODY element to make IE happy
    var tBody = document.createElement("TBODY");
    myTable.appendChild(tBody);
    
    for (var i=0;i<data.unfilled.length;i++) 
    {
        row = tBody.insertRow(-1); row.id = 'req'+data.unfilled[i].id;
        cell = row.insertCell(-1); cell.innerHTML = data.unfilled[i].gid;
        cell = row.insertCell(-1); cell.innerHTML = data.unfilled[i].cid;
        cell = row.insertCell(-1); cell.innerHTML = data.unfilled[i].id;
        cell = row.insertCell(-1); cell.innerHTML = data.unfilled[i].title;
        cell = row.insertCell(-1); cell.innerHTML = data.unfilled[i].author;
        cell = row.insertCell(-1); cell.innerHTML = data.unfilled[i].patron_barcode;
        cell = row.insertCell(-1); cell.innerHTML = data.unfilled[i].ts;
        cell = row.insertCell(-1); cell.innerHTML = data.unfilled[i].from; cell.setAttribute('title', data.unfilled[i].library);
//	var statusWithWhitespace = data.unfilled[i].status;
//	statusWithWhitespace = statusWithWhitespace.replace(/\|/g,' ');
//        cell = row.insertCell(-1); cell.innerHTML = statusWithWhitespace;
        cell = row.insertCell(-1); cell.innerHTML = data.unfilled[i].status;
        cell = row.insertCell(-1); cell.innerHTML = data.unfilled[i].message;
        cell = row.insertCell(-1); cell.innerHTML = data.unfilled[i].pubdate;
        cell = row.insertCell(-1); cell.innerHTML = data.unfilled[i].tried+' of '+data.unfilled[i].sources;
        cell = row.insertCell(-1); 

	var divResponses = document.createElement("div");
	divResponses.id = 'divResponses'+data.unfilled[i].id;

	var b1 = document.createElement("input");
	b1.type = "button";
	b1.value = "Try next lender";
	b1.className = "action-button";
	if (+data.unfilled[i].tried >= +data.unfilled[i].sources) {
	    b1.value = "No further sources";
	    b1.disabled = "disabled";
	}
	var requestId = data.unfilled[i].id;
	b1.onclick = make_trynextlender_handler( requestId );
	divResponses.appendChild(b1);
	
	var b1 = document.createElement("input");
	b1.type = "button";
	b1.value = "Cancel request";
	b1.className = "action-button";
	var requestId = data.unfilled[i].id;
	b1.onclick = make_cancel_handler( requestId );
	divResponses.appendChild(b1);
	
	var b1 = document.createElement("input");
	b1.type = "button";
	b1.value = "Add to wish list";
	b1.className = "action-button";
	var requestId = data.unfilled[i].id;
	b1.onclick = make_acq_handler( requestId );
	divResponses.appendChild(b1);
	
	cell.appendChild( divResponses );
    }
    
    document.getElementById('mylistDiv').appendChild(myTable);
    
    $("#waitDiv").hide();
    $("#mylistDiv").show();
}

// Explanation of why we need a function to create the buttons' onclick handlers:
// http://www.webdeveloper.com/forum/archive/index.php/t-100584.html
// Short answer: scoping and closures

function make_trynextlender_handler( requestId ) {
    return function() { try_next_lender( requestId ) };
}

function try_next_lender( requestId ) {
    var myRow=$("#req"+requestId);
    var parms = {
	reqid: requestId,
	oid: $("#oid").text(),
    }
    $.getJSON('/cgi-bin/try-next-lender.cgi', parms,
	      function(data){
//		  alert('change request status: '+data+'\n'+parms[0].status);
	      })
	.success(function() {
	    //alert('success');
	})
	.error(function() {
	    alert('error');
	})
	.complete(function() {
	    // slideUp doesn't work for <tr>
	    $("#req"+requestId).fadeOut(400, function() { $(this).remove(); }); // toast the row
	});
}

function make_cancel_handler( requestId ) {
    return function() { cancel( requestId ) };
}

function cancel( requestId ) {
    var myRow=$("#req"+requestId);
    var parms = {
	reqid: requestId,
	msg_to: $("#oid").text(),  // message to myself
	oid: $("#oid").text(),
	status: "Message",
	message: "Requester closed the request."
    }
    $.getJSON('/cgi-bin/change-request-status.cgi', parms,
	      function(data){
//		  alert('change request status: '+data+'\n'+parms[0].status);
	      })
	.success(function() {
	    //alert('success');
	    $.getJSON('/cgi-bin/move-to-history.cgi', { 'reqid' : requestId },
		      function(data){
			  //alert('Moved to history? '+data.success+'\n  Closed? '+data.closed+'\n  History? '+data.history+'\n  Active? '+data.active+'\n  Sources? '+data.sources+'\n  Request? '+data.request);
		      });
	})
	.error(function() {
	    alert('error');
	})
	.complete(function() {
	    // slideUp doesn't work for <tr>
	    $("#req"+requestId).fadeOut(400, function() { $(this).remove(); }); // toast the row
	});
}


function make_acq_handler( requestId ) {
    return function() { addToAcq( requestId ) };
}

function addToAcq( requestId ) {
    var myRow=$("#req"+requestId);
    var parms = {
	rid: requestId,
	oid: $("#oid").text(),
    }
    $.getJSON('/cgi-bin/add-request-to-acquisitions.cgi', parms,
	      function(data){
//		  alert('change request status: '+data+'\n'+parms[0].status);
	      })
	.success(function() {
	    //alert('success');
	    cancel( requestId );
	})
	.error(function() {
	    alert('error');
	})
	.complete(function() {
	    // row will get removed in cancel(), if add to acq is successful.
	});
}


