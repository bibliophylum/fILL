// shipping.js
/*
    fILL - Free/Open-Source Interlibrary Loan management system
    Copyright (C) 2012  Government of Manitoba

    shipping.js is a part of fILL.

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
    myTable.setAttribute("id","shipping-table");
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
    cell = document.createElement("TH"); cell.innerHTML = "Author"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Title"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Mailing address"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Last update"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Due date"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Response"; row.appendChild(cell);
    
    var tFoot = myTable.createTFoot();
    row = tFoot.insertRow(-1);
    cell = row.insertCell(-1); cell.colSpan = "11"; cell.innerHTML = "As requests are handled, they are removed from this list.  You can see the status of all of your active ILLs in the \"Current ILLs\" screen.";
    
    // explicit creation of TBODY element to make IE happy
    var tBody = document.createElement("TBODY");
    myTable.appendChild(tBody);
    
    for (var i=0;i<data.shipping.length;i++) 
    {
        row = tBody.insertRow(-1); row.id = 'req'+data.shipping[i].id;
        cell = row.insertCell(-1); cell.innerHTML = data.shipping[i].gid;
        cell = row.insertCell(-1); cell.innerHTML = data.shipping[i].cid;
        cell = row.insertCell(-1); cell.innerHTML = data.shipping[i].id;
        cell = row.insertCell(-1); cell.innerHTML = data.shipping[i].from; cell.setAttribute('title', data.shipping[i].library);
        cell = row.insertCell(-1); cell.innerHTML = data.shipping[i].msg_to;
        cell = row.insertCell(-1); cell.innerHTML = data.shipping[i].author;
        cell = row.insertCell(-1); cell.innerHTML = data.shipping[i].title;
        cell = row.insertCell(-1); cell.innerHTML = data.shipping[i].mailing_address;
        cell = row.insertCell(-1); cell.innerHTML = data.shipping[i].ts;
//        cell = row.insertCell(-1); cell.innerHTML = "";
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

	var requestId = data.shipping[i].id;
	var divResponses = document.createElement("div");
	divResponses.id = 'divResponses'+requestId;

	var $label = $("<label />").text('CP tracking:');
	var $cp = $("<input />").attr({'type':'text',
				       'size':16,
				       'maxlength':16,
				       'style':'font-size:90%',
				       });
	$cp.prop('id','cp'+data.shipping[i].id);
	// make_trackingnumber_handler creates and returns the 
	// function to be called on blur event...
	$cp.blur( make_trackingnumber_handler( data.shipping[i].id ));
	$cp.appendTo( $label );
	divResponses.appendChild( $label[0] );  // [0] converts jQuery var into DOM

	var b1 = document.createElement("input");
	b1.type = "button";
	b1.id = "ship"+requestId;
	b1.value = "Sent - mark item as shipped.";
	// class ship-it-button is used in function set_default_due_date()
	b1.className = "action-button ship-it-button";
	b1.style.fontSize = "150%";
	b1.onclick = make_shipit_handler( requestId );
	divResponses.appendChild(b1);
	
	var b2 = document.createElement("input");
	b2.type = "button";
	b2.id = "unship"+requestId;
	b2.value = "Oops! Return this to the Respond list.";
	// class unship-button is used in function set_default_due_date()
	b2.className = "action-button unship-button";
	b2.onclick = make_unship_handler( requestId );
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

function make_shipit_handler( requestId ) {
    return function() { shipit( requestId ) };
}

function shipit( requestId ) {
    var myRow=$("#req"+requestId);
    var nTr = myRow[0]; // convert jQuery object to DOM
    var oTable = $('#shipping-table').dataTable();
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
	"status": "Shipped",
	"message": "due "+due_date
    };
    $.getJSON('/cgi-bin/change-request-status.cgi', parms,
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

function make_unship_handler( requestId ) {
    return function() { unship( requestId ) };
}

function unship( requestId ) {
    var myRow=$("#req"+requestId);
    var nTr = myRow[0]; // convert jQuery object to DOM
    var oTable = $('#shipping-table').dataTable();
    var aPos = oTable.fnGetPosition( nTr );
    var msg_to = oTable.fnGetData( aPos )[4]; // 5th column (0-based!), hidden or not

    var parms = {
	"reqid": requestId,
	"msg_to": msg_to,
	"lid": $("#lid").text(),
	"status": "Unship",
	"message": ''
    };
    $.getJSON('/cgi-bin/revoke-will-supply-status.cgi', parms,
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

function make_trackingnumber_handler( requestId ) {
    return function() { trackit( requestId ) };
}

function trackit( requestId ) {
    var parms = {
	"rid": requestId,
	"lid": $("#lid").text(),
	"tracking": $("#cp"+requestId).val()
    };
    $.getJSON('/cgi-bin/set-shipping-tracking-number.cgi', parms,
	      function(data){
		  //alert("success: "+data.success);
	      })
	.success(function() {
	    //alert("success!");
	})
	.error(function() {
	    alert('Error adding shipping tracking number.');
	    $("cp"+requestId).focus();
	})
	.complete(function() {
	    //
	});
}

function set_default_due_date(oForm) {
    var defaultDueDate = oForm.elements["datepicker"].value;
    var tbl = $("#shipping-table").DataTable(); // note the capitalized "DataTable"

    $(".due-date").each(function(){
	tbl.cell(this).data( defaultDueDate );
    });

    // using cell.data() recreates the row, losing the dynamically created
    // button handlers in the process.  We need to recreate them:

    $(".ship-it-button").each(function(){
	var requestId = this.id.slice(4); // button id starts with "ship"
	this.onclick = make_shipit_handler( requestId );
    });

    $(".unship-button").each(function(){
	var requestId = this.id.slice(6); // button id starts with "unship"
	this.onclick = make_unship_handler( requestId );
    });

    $(".due-date").stop(true,true).effect("highlight", {}, 2000);
}

