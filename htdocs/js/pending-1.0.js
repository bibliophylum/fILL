// pending.js
/*
    fILL - Free/Open-Source Interlibrary Loan management system
    Copyright (C) 2012  Government of Manitoba

    pending.js is a part of fILL.

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
    var myTable = document.createElement("table");
    myTable.setAttribute("id","pending-table");
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
    cell = document.createElement("TH"); cell.innerHTML = "Request Placed"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Age (days)"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "To"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Status"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Trying lender"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Actions"; row.appendChild(cell);
    
    var tFoot = myTable.createTFoot();
    row = tFoot.insertRow(-1);
    cell = row.insertCell(-1); cell.colSpan = "12"; cell.innerHTML = "If there are more lenders to try, you can click 'Try next lender'.  You can see the status of all of your active ILLs in the \"Current ILLs\" screen.";
    
    // explicit creation of TBODY element to make IE happy
    var tBody = document.createElement("TBODY");
    myTable.appendChild(tBody);
    
    for (var i=0;i<data.noresponse.length;i++) 
    {
        row = tBody.insertRow(-1); row.id = 'req'+data.noresponse[i].id;
        cell = row.insertCell(-1); cell.innerHTML = data.noresponse[i].gid;
        cell = row.insertCell(-1); cell.innerHTML = data.noresponse[i].cid;
        cell = row.insertCell(-1); cell.innerHTML = data.noresponse[i].id;
        cell = row.insertCell(-1); cell.innerHTML = data.noresponse[i].title;
        cell = row.insertCell(-1); cell.innerHTML = data.noresponse[i].author;
        cell = row.insertCell(-1); cell.innerHTML = data.noresponse[i].patron_barcode;
        cell = row.insertCell(-1); cell.innerHTML = data.noresponse[i].ts;
        cell = row.insertCell(-1); cell.innerHTML = data.noresponse[i].age;
        cell = row.insertCell(-1); cell.innerHTML = data.noresponse[i].to; cell.setAttribute('title', data.noresponse[i].library);
        cell = row.insertCell(-1); cell.innerHTML = data.noresponse[i].status;
        cell = row.insertCell(-1); cell.innerHTML = data.noresponse[i].tried+' of '+data.noresponse[i].sources;
        cell = row.insertCell(-1); 

	var divResponses = document.createElement("div");
	divResponses.id = 'divResponses'+data.noresponse[i].id;

	var b1 = document.createElement("input");
	b1.type = "button";
	b1.value = "Try next lender";
	b1.className = "action-button";
	if (+data.noresponse[i].tried >= +data.noresponse[i].sources) {
	    b1.value = "No other lenders";
	    b1.disabled = "disabled";
	}
        if (+data.noresponse[i].age < 3) {
	    // if the request was made less than 3 days ago, disable the try-next-lender button.
	    // note that this only affects the *first* source in the (sorted) sources list; after this,
	    // the request will be in the "unfilled" list instead of this "pending" list.
	    b1.value = "Waiting "+(3 - +data.noresponse[i].age)+( 3 - +data.noresponse[i].age == 1 ? " day" : " days");
	    b1.disabled = "disabled";
	}
	var requestId = data.noresponse[i].id;
	var chainId = data.noresponse[i].cid;
	b1.onclick = make_trynextlender_handler( requestId, chainId );
	divResponses.appendChild(b1);
	
	var b1 = document.createElement("input");
	b1.type = "button";
	b1.value = "Cancel request";
	b1.className = "action-button";
	var requestId = data.noresponse[i].id;
	b1.onclick = make_cancel_handler( requestId );
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

function make_trynextlender_handler( requestId, chainId ) {
    return function() { try_next_lender( requestId, chainId ) };
}

function try_next_lender( requestId, chainId ) {
    var myRow=$("#req"+requestId);
//    var parms = {
//	reqid: requestId,
//	lid: $("#lid").text(),
//    }
//    $.getJSON('/cgi-bin/try-next-lender.cgi', parms,

// Use override.cgi instead of try-next-lender.cgi - we want the override msg
    var parms = {
	cid: chainId,
	override: 'bTryNextLender',
    }
    $.getJSON('/cgi-bin/override.cgi', parms,
	      function(data){
		  if (data.alert_text) { alert(data.alert_text); };
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
	msg_to: $("#lid").text(),  // message to myself
	lid: $("#lid").text(),
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
