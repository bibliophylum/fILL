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

    $('#returns-table').DataTable({
        "jQueryUI": true,
        "pagingType": "full_numbers",
        "info": true,
        "ordering": true,
        "dom": '<"H"Bfr>t<"F"ip>',
	buttons: [ 'copy', 'excel', 'pdf', 'print' ],
        "columnDefs": [
	    {	"targets": [0,1,2,7],
		"visible": false
            },
	    {	"targets": 8, "width": "30%"
	    }
	],
        "initComplete": function() {
            // this handles a bug(?) in this version of datatables;
            // hidden columns caused the table width to be set to 100px, not 100%
            $("#returns-table").css("width","100%");

	    $("#returns-table").DataTable().page.len( parseInt($("#table_rows_per_page").text(),10));
        }
    });

    $.getJSON('/cgi-bin/get-returns-list.cgi', {oid: $("#oid").text()},
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
           update_menu_counters( $("#oid").text() );
    });

});

function build_table( data ) {
    var t = $('#returns-table').DataTable();

    for (var i=0;i<data.returns.length;i++) {

	var divResponses = create_action_buttons( data, i );

	// this should match the fields in the template
	var rdata = [
            data.returns[i].gid,
            data.returns[i].cid,
            data.returns[i].id,
            data.returns[i].title,
            data.returns[i].author,
            data.returns[i].ts,
            data.returns[i].to,
            data.returns[i].msg_to,
	    ""
	];
	var rowNode = t.row.add( rdata ).draw().node();
	$(rowNode).attr("id",'req'+data.returns[i].id);
	// the :eq selector looks at *visible* nodes....
	$(rowNode).children(":eq(3)").attr("title",data.returns[i].library);
	$(rowNode).children(":last").append( divResponses );

	borrowerNotes_insertChild( t, rowNode,
				   data.returns[i].borrower_internal_note,
				   "datatable-detail"
				 );
    }
    borrowerNotes_makeEditable();
}

function create_action_buttons( data, i ) {
    var divResponses = document.createElement("div");
    var requestId = data.returns[i].id;
    divResponses.id = 'divResponses'+requestId;

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
    
    return divResponses;
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
	"oid": $("#oid").text(),
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
	    // toast any child nodes (eg borrower internal notes)
	    var t = $("#returns-table").DataTable();
	    t.row("#req"+requestId).child.remove();
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
	"oid": $("#oid").text(),
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

