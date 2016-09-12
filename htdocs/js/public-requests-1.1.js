// public-requests.js
/*
    fILL - Free/Open-Source Interlibrary Loan management system
    Copyright (C) 2012  Government of Manitoba

    public-requests.js is a part of fILL.

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

// i18n.js will check if this is defined, and if so, will save the table column headings
// translation results here so we can access them dynamcially:
var i18n_tables = 'placeholder';


$('document').ready(function(){
    var anOpenBorrowing = [];
    var sImageUrl = "/plugins/DataTables-1.8.2/examples/examples_support/";

    oTable_borrowing = $('#datatable_borrowing').dataTable({
       "bJQueryUI": true,
        "sPaginationType": "full_numbers",
        "bInfo": true,
      	"bSort": true,
        "searching": false,
	"sDom": '<"H"r>t<"F"ip>',
        "aoColumns": [
            {
               "mDataProp": null,
               "sClass": "control center",
               "sDefaultContent": '<img src="'+sImageUrl+'details_open.png'+'">'
            },
            { "mDataProp": "cid", "bVisible": false },
            { "mDataProp": "title" },
            { "mDataProp": "author" },
            { "mDataProp": "status" },
            { "mDataProp": "details" },
            { "mDataProp": "ts" },
            { "mDataProp": "action" }
        ]

    });
    
    $.getJSON('/cgi-bin/get-patron-requests.cgi',
	      {pid: $("#pid").text(), oid: $("#oid").text() },
              function(data){
                  build_table(data);
		  
		  if (document.documentElement.lang === 'fr') {
                      oTable_borrowing = $('#datatable_borrowing').dataTable({
			  "bJQueryUI": true,
			  "sPaginationType": "full_numbers",
			  "bInfo": true,
      			  "bSort": true,
			  "searching": false,
			  "sDom": '<"H"r>t<"F"ip>',
			  "columnDefs": [{
			      "targets": [0,3],
			      "visible": false
			  }],
			  "initComplete": function(settings, json) {
			      i18n_table_column_headings('#datatable_borrowing');
			      //alert( 'DataTables has finished its initialisation.' );
			  },
			  "language": {
			      "url": '/localisation/DataTables/fr_FR.json'
			  }
		      });
		  } else {
                      oTable_borrowing = $('#datatable_borrowing').dataTable({
			  "bJQueryUI": true,
			  "sPaginationType": "full_numbers",
			  "bInfo": true,
      			  "bSort": true,
			  "searching": false,
			  "sDom": '<"H"r>t<"F"ip>',
			  "columnDefs": [{
			      "targets": [0,3],
			      "visible": false
			  }],
			  "initComplete": function(settings, json) {
			      i18n_table_column_headings('#datatable_borrowing');
			  },
		      });
		  }
              })
	.success(function() {
	    //alert('success');
	})
	.error(function(data) {
	    alert('error');
	})
	.complete(function() {
            //alert('ajax complete');
            // The following is necessary in order to resize the datatable with the
            // hidden 'cid' column (which is necessary for the detail drill-down):
            $('#datatable_borrowing').width("100%");
	});

});

function build_table( data ) {
    var myTable = document.createElement("table");
    myTable.setAttribute("id","datatable_borrowing");
    myTable.className = myTable.className + " row-border";
    var tHead = myTable.createTHead();
    var row = tHead.insertRow(-1);
    var cell;
    // Can't just use:
    // cell = row.insertCell(-1); cell.innerHTML = "ID";
    // ...because insertCell inserts TD elements, and our CSS uses TH for header cells.
    
    cell = document.createElement("TH"); cell.innerHTML = "cid"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Title"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Author"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Lender"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Status"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Details"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Status Updated"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Action"; row.appendChild(cell);
    
    var tFoot = myTable.createTFoot();
    row = tFoot.insertRow(-1);
    cell = row.insertCell(-1); cell.colSpan = "8"; cell.innerHTML = " ";
    
    // explicit creation of TBODY element to make IE happy
    var tBody = document.createElement("TBODY");
    myTable.appendChild(tBody);

    for (var i=0;i<data.active.length;i++) 
    {
	var declinedID = data.active[i].declined_id;  // for declined requests will be prid
	delete data.active[i].declined_id;
	data.active[i].action="";

        row = tBody.insertRow(-1); row.id = 'cid'+data.active[i].cid;
        cell = row.insertCell(-1); cell.innerHTML = data.active[i].cid;
        cell = row.insertCell(-1); cell.innerHTML = data.active[i].title;
        cell = row.insertCell(-1); cell.innerHTML = data.active[i].author;
        cell = row.insertCell(-1); cell.innerHTML = data.active[i].lender;
        cell = row.insertCell(-1); cell.innerHTML = data.active[i].status;
        cell = row.insertCell(-1); cell.innerHTML = data.active[i].details;
        cell = row.insertCell(-1); cell.innerHTML = data.active[i].ts;
	cell = row.insertCell(-1); // actions

	if ((data.active[i].status == 'Declined') || (data.active[i].status == 'Wish list')) {
	    cell.id='declined'+declinedID;
	    row.id = 'row'+declinedID;
	    
	    var divActions = document.createElement("div");
	    divActions.id = 'divActions'+declinedID;
	    
	    var b1 = document.createElement("input");
	    b1.type = "button";
	    b1.className = "action-button";
	    b1.value = "Delete";
	    b1.onclick = make_seenit_handler( declinedID );
	    divActions.appendChild(b1);

	    $(cell).append( divActions );

	} else {
	    // no actions
	}
    }

    document.getElementById('mylistDiv').appendChild(myTable);
    
    $("#waitDiv").hide();
    $("#mylistDiv").show();
}

function make_seenit_handler( declinedID ) {
    return function() { seenit( declinedID ) };
}

function seenit( declinedID ) {
//    $("#declined"+declinedID).fadeOut(400, function() { $(this).remove(); }); // toast the row
//    alert("Seen it! "+declinedID);
    var parms = {
	"prid": declinedID,
	"oid": $("#oid").text()
    };
    $.getJSON('/cgi-bin/delete-declined-patron-request.cgi', parms,
	      function(data){
//		  alert('change request status: '+data+'\n'+parms[0].status);
	      })
	.success(function() {
	})
	.error(function() {
	    alert('error');
	})
	.complete(function() {
	    // slideUp doesn't work for <tr>
	    $("#row"+declinedID).fadeOut(400, function() {
		oTable_borrowing.fnDeleteRow( $("#row"+declinedID)[ 0 ] );
	    }); // toast the row
	});

}

