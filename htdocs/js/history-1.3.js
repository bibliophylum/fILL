// history.js
/*
    fILL - Free/Open-Source Interlibrary Loan management system
    Copyright (C) 2012  Government of Manitoba

    history.js is a part of fILL.

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
function build_table_orig( data ) {
    for (var i=0;i<data.history.borrowing.length;i++) {
	var ai = oTable_borrowing.fnAddData( data.history.borrowing[i], false );
    }
    oTable_borrowing.fnDraw();

    for (var i=0;i<data.history.lending.length;i++) {
	var ai = oTable_lending.fnAddData( data.history.lending[i], false );
    }
    oTable_lending.fnDraw();

    $("#waitDiv").hide();
    $("#tabs").show();
}

function build_table( data ) {
    create_table_borrowing( data );
    build_table_borrowing( data );

    create_table_lending( data );
    build_table_lending( data );
    
    $("#waitDiv").hide();
    $("#tabs").show();
}

function create_table_borrowing( data ) {
    var myTable = document.createElement("table");
    myTable.setAttribute("id","datatable_borrowing");
    var tHead = myTable.createTHead();
    var row = tHead.insertRow(-1);
    var cell;
    // Can't just use:
    // cell = row.insertCell(-1); cell.innerHTML = "ID";
    // ...because insertCell inserts TD elements, and our CSS uses TH for header cells.
    
    cell = document.createElement("TH"); cell.innerHTML = " "; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "gid"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "cid"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Title"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Author"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Patron barcode"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Last update"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Status"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Message"; row.appendChild(cell);
    
    var tFoot = myTable.createTFoot();
    row = tFoot.insertRow(-1);
    cell = row.insertCell(-1); cell.colSpan = "9"; cell.innerHTML = "History of requests you've made to borrow items.";
    
    // explicit creation of TBODY element to make IE happy
    var tBody = document.createElement("TBODY");
    myTable.appendChild(tBody);
    
    document.getElementById('tabs-1').appendChild(myTable);
}
    
function build_table_borrowing( data ) {
    var tBody = $("#datatable_borrowing TBODY")[0];
    for (var i=0;i<data.history.borrowing.length;i++) 
    {
        row = tBody.insertRow(-1); //row.id = 'bc'+data.history.borrowing[i].lid;
        cell = row.insertCell(-1); cell.innerHTML = null;
        cell = row.insertCell(-1); cell.innerHTML = data.history.borrowing[i].gid;
        cell = row.insertCell(-1); cell.innerHTML = data.history.borrowing[i].cid;
        cell = row.insertCell(-1); cell.innerHTML = data.history.borrowing[i].title;
        cell = row.insertCell(-1); cell.innerHTML = data.history.borrowing[i].author;
        cell = row.insertCell(-1); cell.innerHTML = data.history.borrowing[i].patron_barcode;
        cell = row.insertCell(-1); cell.innerHTML = data.history.borrowing[i].ts;
        cell = row.insertCell(-1); cell.innerHTML = data.history.borrowing[i].status;
        cell = row.insertCell(-1); cell.innerHTML = data.history.borrowing[i].message;
    }
}

function create_table_lending( data ) {
    var myTable = document.createElement("table");
    myTable.setAttribute("id","datatable_lending");
    var tHead = myTable.createTHead();
    var row = tHead.insertRow(-1);
    var cell;
    // Can't just use:
    // cell = row.insertCell(-1); cell.innerHTML = "ID";
    // ...because insertCell inserts TD elements, and our CSS uses TH for header cells.
    
    cell = document.createElement("TH"); cell.innerHTML = " "; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "cid"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Title"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Author"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Requested by"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Last update"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Status"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Message"; row.appendChild(cell);
    
    var tFoot = myTable.createTFoot();
    row = tFoot.insertRow(-1);
    cell = row.insertCell(-1); cell.colSpan = "8"; cell.innerHTML = "History of requests other libraries have made for you to lend items.";
    
    // explicit creation of TBODY element to make IE happy
    var tBody = document.createElement("TBODY");
    myTable.appendChild(tBody);
    
    document.getElementById('tabs-2').appendChild(myTable);
}
    
function build_table_lending( data ) {
    var tBody = $("#datatable_lending TBODY")[0];
    for (var i=0;i<data.history.lending.length;i++) 
    {
        row = tBody.insertRow(-1); //row.id = 'bc'+data.history.borrowing[i].lid;
        cell = row.insertCell(-1); cell.innerHTML = null;
        cell = row.insertCell(-1); cell.innerHTML = data.history.lending[i].cid;
        cell = row.insertCell(-1); cell.innerHTML = data.history.lending[i].title;
        cell = row.insertCell(-1); cell.innerHTML = data.history.lending[i].author;
        cell = row.insertCell(-1); cell.innerHTML = data.history.lending[i].requested_by; cell.setAttribute('title', data.history.lending[i].library);
        cell = row.insertCell(-1); cell.innerHTML = data.history.lending[i].ts;
        cell = row.insertCell(-1); cell.innerHTML = data.history.lending[i].status;
        cell = row.insertCell(-1); cell.innerHTML = data.history.lending[i].message;
    }
}

function fnFormatDetails( $tbl, nTr )
{
    var oTable = $tbl.dataTable();
    var aData = oTable.fnGetData( nTr );
//    alert('getting details for reqid: '+oData.id);

    var cid;
    var id = $tbl.attr("id");
    if (id == "datatable_borrowing") {
        cid = aData[2];
    } else if (id == "datatable_lending") {
        cid = aData[1];
    }

    $.getJSON('/cgi-bin/get-history-details.cgi', { "cid": cid },
	      function(data){
		  //alert('first success');
	      })
	.success(function() {
	    //alert('success');
	})
	.error(function() {
	    alert('error');
	})
	.complete(function(jqXHRObject) {
	    var data = $.parseJSON(jqXHRObject.responseText)
	    var sOut;
	    var numDetails = data.request_history.length; 
	    sOut = '<div class="innerDetails">'+
		'<table id="gradient-style" cellpadding="5" cellspacing="0" border="0" style="padding-left:50px;">'+
		'<thead><th>Request ID</th><th>Timestamp</th><th>Msg from</th><th>Msg to</th><th>Status</th><th>Extra information</th></thead>';
	    for (var i = 0; i < numDetails; i++) {
		var detRow = '<tr>'+
		    '<td>'+data.request_history[i].request_id+'</td>'+
		    '<td>'+data.request_history[i].ts+'</td>'+
		    '<td>'+data.request_history[i].from+'</td>'+
		    '<td>'+data.request_history[i].to+'</td>'+
		    '<td>'+data.request_history[i].status+'</td>'+
		    '<td>'+data.request_history[i].message+'</td>'+
		    '</tr>';
		sOut=sOut+detRow;
	    }
	    sOut = sOut+'</table>'+'</div>';
            var nDetailsRow = oTable.fnOpen( nTr, sOut, 'details' );
            $('div.innerDetails', nDetailsRow).slideDown();

	});
}

function dt_init() {
    var sImageUrl = "/plugins/DataTables-1.8.2/examples/examples_support/";

    oTable_borrowing = $('#datatable_borrowing').dataTable({
        "bJQueryUI": true,
        "sPaginationType": "full_numbers",
        "bInfo": true,
        "bSort": true,
        "bDestroy": true,
        "sDom": '<"H"Tfr>t<"F"ip>',
        "oTableTools": {
            "sSwfPath": "/plugins/DataTables-1.10.2/extensions/TableTools/swf/copy_csv_xls_pdf.swf"
        },
        "columnDefs": [{
            "targets": 0,
            "data": null,
            "defaultContent": '<img src="'+sImageUrl+'details_open.png'+'">',
            "className": "control center"
        },{
            "targets": [1,2],
            "visible": false
        }],
        "fnInitComplete": function() {
            // this handles a bug(?) in this version of datatables;
            // hidden columns caused the table width to be set to 100px, not 100%
            $("#datatable_borrowing").css("width","100%");
        }
    });

    oTable_lending = $('#datatable_lending').dataTable({
        "bJQueryUI": true,
        "sPaginationType": "full_numbers",
        "bInfo": true,
        "bSort": true,
        "bDestroy": true,
        "sDom": '<"H"Tfr>t<"F"ip>',
        "oTableTools": {
            "sSwfPath": "/plugins/DataTables-1.8.2/extras/TableTools/media/swf/copy_csv_xls_pdf.swf"
        },
        "columnDefs": [{
            "targets": 0,
            "data": null,
            "defaultContent": '<img src="'+sImageUrl+'details_open.png'+'">',
            "className": "control center"
        },{
            "targets": 1,
            "visible": false
        }],
        "fnInitComplete": function() {
            // this handles a bug(?) in this version of datatables;
            // hidden columns caused the table width to be set to 100px, not 100%
            $("#datatable_lending").css("width","100%");
        }
    });
}

function requery( lid, anOpenBorrowing, anOpenLending ) 
{
    var d_s = moment( $("#startdate").datepicker("getDate") ).format("YYYY-MM-DD");
    var d_e = moment( $("#enddate").datepicker("getDate") ).format("YYYY-MM-DD");

    $("#waitDiv").show();
    $("#tabs").hide();
    $("#dateButton").prop('disabled', true);

    $.getJSON('/cgi-bin/get-history.cgi', { "lid":   lid,
                                            "start": d_s, 
                                            "end":   d_e
                                          },
              function(data){
		  $("#datatable_borrowing_wrapper").remove();
		  $("#datatable_lending_wrapper").remove();

                  build_table(data);
		  dt_init();  // set up the tables as DataTables

              })
    	.success(function() {
	    // alert('success');
	    $("#waitDiv").hide();
	    $("#tabs").show();
	    $("#dateButton").prop('disabled', false);
       	})
       	.error(function() {
            alert('error');
       	})
       	.complete(function() {
	    // alert('ajax complete');
	    // reset the arrays that track open details:
            anOpenBorrowing.length = 0;
            anOpenLending.length = 0;
	    // make the details buttons clickable:
	    activate_detail_control( $("#datatable_borrowing"), anOpenBorrowing );
	    activate_detail_control( $("#datatable_lending"),   anOpenLending   );
       	});
};

function activate_detail_control( $tbl, anOpen ) {

    $tbl.on("click", "td.control", function() {
      var nTr = this.parentNode;
      var i = $.inArray( nTr, anOpenBorrowing );
      var sImageUrl = "/plugins/DataTables-1.8.2/examples/examples_support/";
   
      if ( i === -1 ) {
        $('img', this).attr( 'src', sImageUrl+"details_close.png" );
	fnFormatDetails($tbl, nTr);
        anOpen.push( nTr );
      }
      else {
        $('img', this).attr( 'src', sImageUrl+"details_open.png" );
        $('div.innerDetails', $(nTr).next()[0]).slideUp( function () {
          $tbl.fnClose( nTr );
          anOpen.splice( i, 1 );
        });
      }
    });

}

