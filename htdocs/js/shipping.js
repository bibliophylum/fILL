// shipping.js
/*
    fILL - Free/Open-Source Interlibrary Loan management system
    Copyright (C) 2012  David A. Christensen

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
function build_table( data ) {
//    alert( 'in build_table' );
    var myTable = document.createElement("table");
    myTable.setAttribute("id","gradient-style");
    var tHead = myTable.createTHead();
    var row = tHead.insertRow(-1);
    var cell;
    // Can't just use:
    // cell = row.insertCell(-1); cell.innerHTML = "ID";
    // ...because insertCell inserts TD elements, and our CSS uses TH for header cells.
    
    cell = document.createElement("TH"); cell.innerHTML = "ID"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "From"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "From (ID)"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Author"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Title"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Mailing address"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Timestamp"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Due date"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Response"; row.appendChild(cell);
    
    var tFoot = myTable.createTFoot();
    row = tFoot.insertRow(-1);
    cell = row.insertCell(-1); cell.colSpan = "9"; cell.innerHTML = "As requests are handled, they are removed from this list.  You can see the status of all of your active ILLs in the \"Current ILLs\" screen.";
    
    // explicit creation of TBODY element to make IE happy
    var tBody = document.createElement("TBODY");
    myTable.appendChild(tBody);
    
//    alert('building rows');
    for (var i=0;i<data.shipping.length;i++) 
    {
//	alert (data.shipping[i].id+" "+data.shipping[i].msg_from+" "+data.shipping[i].call_number+" "+data.shipping[i].author+" "+data.shipping[i].title+" "+data.shipping[i].ts); //further debug
        row = tBody.insertRow(-1); row.id = 'req'+data.shipping[i].id;
        cell = row.insertCell(-1); cell.innerHTML = data.shipping[i].id;
        cell = row.insertCell(-1); cell.innerHTML = data.shipping[i].from; cell.setAttribute('title', data.shipping[i].library);
        cell = row.insertCell(-1); cell.innerHTML = data.shipping[i].msg_to;
        cell = row.insertCell(-1); cell.innerHTML = data.shipping[i].author;
        cell = row.insertCell(-1); cell.innerHTML = data.shipping[i].title;
        cell = row.insertCell(-1); cell.innerHTML = data.shipping[i].mailing_address;
        cell = row.insertCell(-1); cell.innerHTML = data.shipping[i].ts;
        cell = row.insertCell(-1); cell.innerHTML = "";
        cell = row.insertCell(-1); 

	var requestId = data.shipping[i].id;
	var divResponses = document.createElement("div");
	divResponses.id = 'divResponses'+requestId;

	var b3 = document.createElement("input");
	b3.type = "button";
	b3.value = "Canada Post";
	b3.onclick = make_canada_post_handler( requestId );
	divResponses.appendChild(b3);

	var b1 = document.createElement("input");
	b1.type = "button";
	b1.value = "Sent";
	b1.onclick = make_shipit_handler( requestId );
	divResponses.appendChild(b1);
	
	cell.appendChild( divResponses );
    }
    
    document.getElementById('mylistDiv').appendChild(myTable);
    
    toggleLayer("waitDiv");
    toggleLayer("mylistDiv");
}

// Explanation of why we need a function to create the buttons' onclick handlers:
// http://www.webdeveloper.com/forum/archive/index.php/t-100584.html
// Short answer: scoping and closures

function make_shipit_handler( requestId ) {
    return function() { shipit( requestId ) };
}

function shipit( requestId ) {
    // NOTE: this code will find table rows based on cell contents...
    // ...as we now have <tr id='xxx'>, there's an easier way....

    // Returns [{reqid: 12, msg_to: '101'}, 
    //          {reqid: 15, msg_to: '98'},
    // Note that nth-child uses 1-based indexing, not 0-based
    var parms = $('#gradient-style tbody tr').map(function() {
	// $(this) is used more than once; cache it for performance.
	var $row = $(this);
	
	// For each row that's "mapped", return an object that
	//  describes the first and second <td> in the row.
	if ($row.find(':nth-child(1)').text() == requestId) {
	    return {
		reqid: $row.find(':nth-child(1)').text(),
		msg_to: $row.find(':nth-child(3)').text(),  // sending TO whoever original was FROM
		lid: $("#lid").text(),
		status: "Shipped",
		message: "due "+$row.find(':nth-child(8)').text()
	    }
	} else {
	    return null;
	};
    }).get();

    $.getJSON('/cgi-bin/change-request-status.cgi', parms[0],
	      function(data){
//		  alert('change request status: '+data+'\n'+parms[0].status);
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

function make_canada_post_handler( requestId ) {
    return function() { canada_post( requestId ) };
}

function canada_post( requestId ) {
    var row = $("#req"+requestId);
    var cpDiv = document.createElement("div");
    cpDiv.id = "canadaPost";
    $.getJSON('/cgi-bin/get-canada-post-form-data.cgi', {reqid: requestId},
	      function(data){
		  //alert(data.shipment.customer_ref1);
		  var cpForm = document.createElement("form");
		  cpForm.setAttribute('id','cpForm');
		  var cp = document.createElement("div");
		  cp.setAttribute('id','canadapost');

		  cpForm.appendChild(cp);
		  cpDiv.appendChild(cpForm);
		  $("<tr id='tmprow'><td></td><td id='tmpcol' colspan='9'></td></tr>").insertAfter($("#req"+requestId));
		  $("#tmpcol").append(cpDiv);
		  
		  $("#divResponses"+requestId).hide();
		  
		  // build the mini-form
		  $("<table id='cpTable'><thead><tr><td>Shipment</td><td>SENDER</td><td>DESTINATION</td><td>REQUIRED FIELDS</td></tr></thead><tbody></tbody></table>").appendTo(cpForm);
		  $('#cpTable > tbody:last').append("<tr></tr>");

		  $('#cpTable > tbody > tr:last').append("<td id='cpTableShipInfo'></td>");
		  $('#cpTableShipInfo').append("<p>For now, assume Library Book Rate</p>");
		  $('#cpTableShipInfo').append("<p>group id: "+data.shipment.group_id+"</p>");
		  $('#cpTableShipInfo').append("<p>expected mailing date: "+data.shipment.expected_mailing_date+"</p>");
		  $('#cpTableShipInfo').append("<p>service code: "+data.shipment.service_code+"</p>");
		  
		  $('#cpTable > tbody > tr:last').append("<td id='cpTableSender'></td>");
		  $('#cpTableSender').append("<p>"+data.shipment.sender.name+"</p>");
		  $('#cpTableSender').append("<p>"+data.shipment.sender.company+"</p>");
		  $('#cpTableSender').append("<p>"+data.shipment.sender.address_line1+"</p>");
		  $('#cpTableSender').append("<p>"+data.shipment.sender.city+", "+data.shipment.sender.province+"  "+data.shipment.sender.postal_code+"</p>");
		  $('#cpTableSender').append("<br/>");
		  $('#cpTableSender').append("<p>Phone: "+data.shipment.sender.contact_phone+"</p>");
		  $('#cpTableSender').append("<p>Email: "+data.shipment.sender.email_address+"</p>");
		  
		  $('#cpTable > tbody > tr:last').append("<td id='cpTableDestination'></td>");
		  $('#cpTableDestination').append("<p>"+data.shipment.destination.name+"</p>");
		  $('#cpTableDestination').append("<p>"+data.shipment.destination.company+"</p>");
		  $('#cpTableDestination').append("<p>"+data.shipment.destination.address_line1+"</p>");
		  $('#cpTableDestination').append("<p>"+data.shipment.destination.city+", "+data.shipment.sender.province+"  "+data.shipment.sender.postal_code+"</p>");
		  $('#cpTableDestination').append("<br/>");
		  $('#cpTableDestination').append("<p>Phone: "+data.shipment.destination.contact_phone+"</p>");
		  $('#cpTableDestination').append("<p>Email: "+data.shipment.destination.email_address+"</p>");
		  
		  $('#cpTable > tbody > tr:last').append("<td id='cpTableRequiredFields'></td>");
		  $('#cpTableRequiredFields').append("<input type='hidden' name='reqid' value='"+requestId+"'>");
		  $('#cpTableRequiredFields').append("<p>Weight:<input type='text' name='weight'>(kg)</p>");
		  $('#cpTableRequiredFields').append("<p>Email notification</p>");
		  $('#cpTableRequiredFields').append("<p><input type='radio' name='notifyShipment' value='true'>Yes, <input type='radio' name='notifyShipment' value='false' checked>No : on-shipment</p>");
		  $('#cpTableRequiredFields').append("<p><input type='radio' name='notifyException' value='true' checked>Yes, <input type='radio' name='notifyException' value='false'>No : on-exception</p>");
		  $('#cpTableRequiredFields').append("<p><input type='radio' name='notifyDelivery' value='true'>Yes, <input type='radio' name='notifyDelivery' value='false' checked>No : on-delivery</p>");

		  var cButton = $("<input type='button' value='Cancel'>").appendTo(cpForm);
		  cButton.bind('click', function() {
		      $("#canadaPost").remove(); 
		      $("#tmprow").remove();
		      $("#divResponses"+requestId).show(); 
		      //return false;
		  });
		  
		  var sButton = $("<input type='submit' value='Submit'>").appendTo(cpForm);
		  sButton.bind('click', function() {
		      $("#cpForm").append("<img src='/wait.gif'>");
		      var s=$("#cpForm").serialize();
		      $.getJSON('/cgi-bin/canada-post-create-shipment.cgi', $("#cpForm").serialize(),
		      		function(data){
				    // remove the now-submitted form
				    $("#cpForm").remove();
				    
				    // display the submission results
				    var cp = document.createElement("div");
				    cp.setAttribute('id','canadapost');
				    cpDiv.appendChild(cp);

				    $("#canadapost").append("<h2>Canada Post tracking #: "+data.cp_response.tracking_pin+"</h2>");
				    var sOut = '<table id="gradient-style" cellpadding="5" cellspacing="0" border="0" style="padding-left:50px;">'+
					'<thead><th>Action</th><th>Description</th></thead>';
				    sOut = sOut+'<tr><td><button id="bPrintLabel">Print label</button></td><td>Open the PDF of the Canada Post mailing label.<br/>You can always reprint the Canada Post mailing label from the Current ILLs tab.</td></tr>';
				    sOut = sOut+'</table>'+'</div>';
				    $("#canadapost").append(sOut);
				    $('#bPrintLabel').button();
				    $('#bPrintLabel').click(function() { 
					$("#bPrintLabel").parent().append("<img src='/wait.gif'>");
					window.open('/cgi-bin/canada-post-get-label.cgi?reqid='+requestId);
					$("#bPrintLabel").next().remove(); // toast the wait image
					return false; 
				    });

		      		})
		      	  .success(function() {
//			      $("#canadaPost").remove(); 
//			      $("#tmprow").remove();
//			      $("#divResponses"+requestId).show(); 
			  })
			  .error(function() {
			      alert('urk!');
		      	  });

		      return false;
		  });
	      })
	.success(function() {
	    //alert('success!');
	});  // .getJSON get-canada-post-form-data
}

function set_default_due_date(oForm) {
//    var defaultDueDate = oForm.elements["year"].value + '-' + oForm.elements["month"].value + '-' + oForm.elements["day"].value;
    var defaultDueDate = oForm.elements["datepicker"].value;
    var theTable = document.getElementById('gradient-style');

    for( var r = 0; r < theTable.tBodies[0].rows.length; r++ ) {
	theTable.tBodies[0].rows[r].cells[7].innerHTML = defaultDueDate;
    }
    $("#gradient-style > tbody > tr > td:nth-child(8)").stop(tcpe,true).effect("highlight", {}, 2000);
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
    //    alert('toggled ' + whichLayer);
}

function set_primary_tab(tab_id) {
    document.getElementById(tab_id).className='current_tab';
}

function set_secondary_tab(tab_id) {
    document.getElementById(tab_id).className='current_tab';
}


