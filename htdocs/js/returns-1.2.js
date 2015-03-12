// returns.js
/*
    fILL - Free/Open-Source Interlibrary Loan management system
    Copyright (C) 2012  Government of Manitoba

    returns.js is a part of fILL.

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

    $.getJSON('/cgi-bin/get-returns-list.cgi', {lid: $("#lid").text()},
            function(data){
                //alert (data.returns[0].id+" "+data.returns[0].msg_from+" "+data.returns[0].call_number+" "+data.returns[0].author+" "+data.returns[0].title+" "+data.returns[0].ts); //further debug
                build_table(data);

                $('#returns-table').DataTable({
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
                       },
                       { "targets": 8, "width": "30%" }
	               ],
                      "initComplete": function() {
                          // this handles a bug(?) in this version of datatables;
                          // hidden columns caused the table width to be set to 100px, not 100%
                          $("#returns-table").css("width","100%");
                      }
                  });
           });

    $(function() {
           update_menu_counters( $("#lid").text() );
    });

});

function build_table( data ) {
//    alert( 'in build_table' );
    var myTable = document.createElement("table");
    myTable.setAttribute("id","returns-table");
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
    cell = document.createElement("TH"); cell.innerHTML = "Last update"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Return to"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Return to (ID)"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Actions"; row.appendChild(cell);
    
    var tFoot = myTable.createTFoot();
    row = tFoot.insertRow(-1);
    cell = row.insertCell(-1); cell.colSpan = "9"; cell.innerHTML = "As items are returned, they are removed from this list.  You can see the status of all of your active ILLs in the \"Current ILLs\" screen.";
    
    // explicit creation of TBODY element to make IE happy
    var tBody = document.createElement("TBODY");
    myTable.appendChild(tBody);
    
//    alert('building rows');
    for (var i=0;i<data.returns.length;i++) 
    {
//	alert (data.returns[i].id+" "+data.returns[i].msg_from+" "+data.returns[i].call_number+" "+data.returns[i].author+" "+data.returns[i].title+" "+data.returns[i].ts); //further debug
        row = tBody.insertRow(-1); row.id = 'req'+data.returns[i].id;
        cell = row.insertCell(-1); cell.innerHTML = data.returns[i].gid;
        cell = row.insertCell(-1); cell.innerHTML = data.returns[i].cid;
        cell = row.insertCell(-1); cell.innerHTML = data.returns[i].id;
        cell = row.insertCell(-1); cell.innerHTML = data.returns[i].title;
        cell = row.insertCell(-1); cell.innerHTML = data.returns[i].author;
        cell = row.insertCell(-1); cell.innerHTML = data.returns[i].ts;
        cell = row.insertCell(-1); cell.innerHTML = data.returns[i].to; cell.setAttribute('title', data.returns[i].library);
        cell = row.insertCell(-1); cell.innerHTML = data.returns[i].msg_to;
        cell = row.insertCell(-1); 

	var divResponses = document.createElement("div");
	divResponses.id = 'divResponses'+data.returns[i].id;

	var $label = $("<label />").text('CP tracking:');
	var $cp = $("<input />").attr({'type':'text',
				       'size':16,
				       'maxlength':16,
				       'style':'font-size:90%',
				       });
	$cp.prop('id','cp'+data.returns[i].id);
	// make_trackingnumber_handler creates and returns the 
	// function to be called on blur event...
	$cp.blur( make_trackingnumber_handler( data.returns[i].id ));
	$cp.appendTo( $label );
	divResponses.appendChild( $label[0] );  // [0] converts jQuery var into DOM

	var b1 = document.createElement("input");
	b1.type = "button";
	b1.value = "Return";
	b1.className = "action-button";
	b1.onclick = make_returns_handler( data.returns[i].id );
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

function make_returns_handler( requestId ) {
    return function() { return_item( requestId ) };
}

function return_item( requestId ) {
    var myRow=$("#req"+requestId);
    var nTr = myRow[0]; // convert jQuery object to DOM
    var oTable = $('#returns-table').dataTable();
    var aPos = oTable.fnGetPosition( nTr );
    var msg_to = oTable.fnGetData( aPos )[7]; // 8th column (0-based!), hidden or not

    var parms = {
	"reqid": requestId,
	"msg_to": msg_to,
	"lid": $("#lid").text(),
	"status": "Returned",
	"message": ""
    };
    $.getJSON('/cgi-bin/change-request-status.cgi', parms,
	      function(data){
//		  alert('change request status: '+data+'\n'+parms[0].status);
	      })
	.success(function() {
	    // alert('success');
	    // print slip (single) / add to slip page (multi) / do nothing (none)
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

