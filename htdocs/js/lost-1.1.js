// lost.js
/*
    fILL - Free/Open-Source Interlibrary Loan management system
    Copyright (C) 2012  Government of Manitoba

    lost.js is a part of fILL.

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

  $.getJSON('/cgi-bin/get-lost-list.cgi', {oid: $("#oid").text()},
    function(data){
    
      build_table(data); 
    
      $('#lost-table').DataTable({
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
        } ],
        "initComplete": function() {
          // this handles a bug(?) in this version of datatables;
          // hidden columns caused the table width to be set to 100px, not 100%
          $("#lost-table").css("width","100%");
        }
      });
    });

  $(function() {
    update_menu_counters( $("#oid").text() );
  });

});

function build_table( data ) {
    var myTable = document.createElement("table");
    myTable.setAttribute("id","lost-table");
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
    cell = document.createElement("TH"); cell.innerHTML = "Date"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "From"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Phone"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Address"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Status"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Message"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Actions"; row.appendChild(cell);
    
    var tFoot = myTable.createTFoot();
    row = tFoot.insertRow(-1);
    cell = row.insertCell(-1); cell.colSpan = "12"; cell.innerHTML = "When you are finished with a particular row (e.g. used the information to create a bill), click the 'Move to history' button.";
    
    // explicit creation of TBODY element to make IE happy
    var tBody = document.createElement("TBODY");
    myTable.appendChild(tBody);
    
    for (var i=0;i<data.lostlist.length;i++) 
    {
        row = tBody.insertRow(-1); row.id = 'req'+data.lostlist[i].id;
        cell = row.insertCell(-1); cell.innerHTML = data.lostlist[i].gid;
        cell = row.insertCell(-1); cell.innerHTML = data.lostlist[i].cid;
        cell = row.insertCell(-1); cell.innerHTML = data.lostlist[i].id;
        cell = row.insertCell(-1); cell.innerHTML = data.lostlist[i].title;
        cell = row.insertCell(-1); cell.innerHTML = data.lostlist[i].author;
        cell = row.insertCell(-1); cell.innerHTML = data.lostlist[i].ts;
        cell = row.insertCell(-1); cell.innerHTML = data.lostlist[i].from; cell.setAttribute('title', data.lostlist[i].library);
        cell = row.insertCell(-1); cell.innerHTML = data.lostlist[i].phone;
        cell = row.insertCell(-1); cell.innerHTML = data.lostlist[i].library+'<br />'+data.lostlist[i].mailing_address_line1+'<br />'+data.lostlist[i].mailing_address_line2+'<br />'+data.lostlist[i].mailing_address_line3+'<br />'+data.lostlist[i].city+', '+data.lostlist[i].province+'  '+data.lostlist[i].postcode;
        cell = row.insertCell(-1); cell.innerHTML = data.lostlist[i].status;
        cell = row.insertCell(-1); cell.innerHTML = data.lostlist[i].message;
        cell = row.insertCell(-1); 

	var divResponses = document.createElement("div");
	divResponses.id = 'divResponses'+data.lostlist[i].id;

	var b1 = document.createElement("input");
	b1.type = "button";
	b1.value = "Move to history";
	b1.className = "action-button";
	var requestId = data.lostlist[i].id;
	b1.onclick = make_movetohistory_handler( requestId );
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

function make_movetohistory_handler( requestId ) {
    return function() { move_to_history( requestId ) };
}

function move_to_history( requestId ) {
    var myRow=$("#req"+requestId);
    var parms = {
	reqid: requestId,
	msg_to: $("#oid").text(),  // message to myself
	oid: $("#oid").text(),
	status: "Message",
	message: "Lender closed the request (borrower lost item)."
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
