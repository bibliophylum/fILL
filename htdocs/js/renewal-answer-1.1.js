// renewal-answer.js
/*
    fILL - Free/Open-Source Interlibrary Loan management system
    Copyright (C) 2012  Government of Manitoba

    renewal-answer.js is a part of fILL.

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
    myTable.setAttribute("id","renewal-answer-table");
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
    cell = document.createElement("TH"); cell.innerHTML = "From"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "From (ID)"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Call #"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Author"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Title"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Last update"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Due date"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Action"; row.appendChild(cell);
    
    var tFoot = myTable.createTFoot();
    row = tFoot.insertRow(-1);
    cell = row.insertCell(-1); cell.colSpan = "11"; cell.innerHTML = "As requests are handled, they are removed from this list.  You can see the status of all of your active ILLs in the \"Current ILLs\" screen.";
    
    // explicit creation of TBODY element to make IE happy
    var tBody = document.createElement("TBODY");
    myTable.appendChild(tBody);
    
    for (var i=0;i<data.renewRequests.length;i++) 
    {
        row = tBody.insertRow(-1); row.id = 'req'+data.renewRequests[i].id;
        cell = row.insertCell(-1); cell.innerHTML = data.renewRequests[i].gid;
        cell = row.insertCell(-1); cell.innerHTML = data.renewRequests[i].cid;
        cell = row.insertCell(-1); cell.innerHTML = data.renewRequests[i].id;
        cell = row.insertCell(-1); cell.innerHTML = data.renewRequests[i].from; cell.setAttribute('title', data.renewRequests[i].library);
        cell = row.insertCell(-1); cell.innerHTML = data.renewRequests[i].msg_from;
        cell = row.insertCell(-1); cell.innerHTML = data.renewRequests[i].call_number;
        cell = row.insertCell(-1); cell.innerHTML = data.renewRequests[i].author;
        cell = row.insertCell(-1); cell.innerHTML = data.renewRequests[i].title;
        cell = row.insertCell(-1); cell.innerHTML = data.renewRequests[i].ts;
	// Need to set a default due date:
	var now = new Date();
	var d = new Date(now.getTime() + (27 * 24 * 60 * 60 * 1000)); 
// Doesn't work on older version of Internet Explorer...
//	var iso = d.toISOString();
	var month = d.getMonth()+1;
	var day = d.getDate();
	var iso = d.getFullYear() + '-' +
	    ((''+month).length<2 ? '0' : '') + month + '-' +
	    ((''+day).length<2 ? '0' : '') + day;
        cell = row.insertCell(-1); cell.innerHTML = iso.substring(0,10); cell.setAttribute('class','due-date');
        cell = row.insertCell(-1); 

	var requestId = data.renewRequests[i].id;
	var divResponses = document.createElement("div");
	divResponses.id = 'divResponses'+requestId;

	var b1 = document.createElement("input");
	b1.type = "button";
	b1.id = "renew"+requestId;
	b1.value = "Renew OK";
	// class renew-it-button is used in function set_default_due_date()
	b1.className = "action-button renew-it-button";
	b1.onclick = make_renewalAnswer_handler( requestId );
	divResponses.appendChild(b1);
	
	var b2 = document.createElement("input");
	b2.type = "button";
	b2.id = "norenew"+requestId;
	b2.value = "Can\'t renew";
	// class no-renew-button is used in function set_default_due_date()
	b2.className = "action-button no-renew-button";
	b2.onclick = make_cannotRenew_handler( requestId );
	divResponses.appendChild(b2);

	cell.appendChild( divResponses );
    }
    
    document.getElementById('mylistDiv').appendChild(myTable);
    
    $("#waitDiv").hide();
    $("#mylistDiv").show();
}

// Explanation of why we need a function to create the buttons' onclick handlers:
// http://www.webdeveloper.com/forum/archive/index.php/t-100584.html
// Short answer: scoping and closures

function make_renewalAnswer_handler( requestId ) {
    return function() { renewalAnswer( requestId ) };
}

function renewalAnswer( requestId ) {
    var myRow=$("#req"+requestId);
    var nTr = myRow[0]; // convert jQuery object to DOM
    var oTable = $('#renewal-answer-table').dataTable();
    var aPos = oTable.fnGetPosition( nTr );
    var msg_to = oTable.fnGetData( aPos )[4]; // 5th column (0-based!), hidden or not
    var due_date = oTable.fnGetData( aPos )[9];

    if (due_date.length == 0) {
	var retVal = confirm("You have not entered a due date.  Continue without due date?");
	if (retVal == false) {
	    // bail out to let the user enter a due date
 	    return false;
	}
    }

    var parms = {
	"reqid": requestId,
	"msg_to": msg_to,
	"lid": $("#lid").text(),
	"status": "Renew-Answer|Ok",
	"message": "due "+due_date
    };
    $.getJSON('/cgi-bin/change-request-status.cgi', parms,
	      function(data){
		  //alert('change request status: '+data+'\n'+parms.status);
	      })
        .success(function() {
	    update_menu_counters( $("#lid").text() );
	})
	.error(function() {
	    alert('error');
	})
	.complete(function() {
	    // slideUp doesn't work for <tr>
	    $("#req"+requestId).fadeOut(400, function() { $(this).remove(); }); // toast the row
	});
}

function make_cannotRenew_handler( requestId ) {
    return function() { cannotRenew( requestId ) };
}

function cannotRenew( requestId ) {
    var myRow=$("#req"+requestId);
    var nTr = myRow[0]; // convert jQuery object to DOM
    var oTable = $('#renewal-answer-table').dataTable();
    var aPos = oTable.fnGetPosition( nTr );
    var msg_to = oTable.fnGetData( aPos )[4]; // 5th column (0-based!), hidden or not

    var crDiv = document.createElement("div");
    crDiv.id = "cannotRenewMessage";
    var crForm = document.createElement("form");
    crDiv.appendChild(crForm);
    $("#divResponses"+requestId).after( crDiv ); // crDiv is sibling of divResponses

    $("#divResponses"+requestId).hide();

    $("<p />").text("You can enter a message if you'd like:").appendTo(crForm);
    $("<input />").attr({'type':'text','id':'crmsg'}).appendTo(crForm);
    var cButton = $("<input type='button' class='action-button' value='Cancel'>").appendTo(crForm);
    cButton.bind('click', function() {
	$("#cannotRenewMessage").remove(); 
	$("#divResponses"+requestId).show(); 
	//return false;
    });

    var sButton = $("<input type='button' class='action-button' value='Submit'>").appendTo(crForm);
    sButton.bind('click', function() {
	var reason = $('#crmsg').val();
	alert( reason );
	$("#cannotRenewMessage").remove(); 
	$("#divResponses"+requestId).show(); 
	var parms = {
	    "reqid": requestId,
	    "msg_to": msg_to,
	    "lid": $("#lid").text(),
	    "status": "Renew-Answer|No-renewal",
	    "message": reason
	};

	$.getJSON('/cgi-bin/change-request-status.cgi', parms,
		  function(data){
		      //alert('change request status: '+data+'\n'+parms.status);
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
    });
}

function set_default_due_date(oForm) {
    var defaultDueDate = oForm.elements["datepicker"].value;
    var tbl = $("#renewal-answer-table").DataTable(); // note the capitalized "DataTable"

    $(".due-date").each(function(){
	tbl.cell(this).data( defaultDueDate );
    });

    // using cell.data() recreates the row, losing the dynamically created
    // button handlers in the process.  We need to recreate them:

    $(".renew-it-button").each(function(){
	var requestId = this.id.slice(5); // button id starts with "renew"
	this.onclick = make_renewalAnswer_handler( requestId );
    });

    $(".no-renew-button").each(function(){
	var requestId = this.id.slice(7); // button id starts with "norenew"
	this.onclick = make_cannotRenew_handler( requestId );
    });

    $(".due-date").stop(true,true).effect("highlight", {}, 2000);
}
