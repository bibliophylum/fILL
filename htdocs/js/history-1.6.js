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
var anOpenBorrowing;
var anOpenLending;

$('document').ready(function(){
    set_primary_tab("menu_history");

    anOpenBorrowing = [];
    anOpenLending = [];

    var sImageUrl = "/img/";

    $('#datatable_borrowing').dataTable({
        "bJQueryUI": true,
        "sPaginationType": "full_numbers",
        "bInfo": true,
        "bSort": true,
        "bDestroy": true,
        "sDom": '<"H"Bfr>t<"F"ip>',
	buttons: [ 'copy', 'excel', 'pdf', 'print' ],
        "columnDefs": [
	    { "targets": 0,
              "data": null,
              "defaultContent": '<img src="'+sImageUrl+'details_open.png'+'">',
              "className": "control center"
            },
	    { "targets": [1,2],
	      "visible": false
            }],
        "fnInitComplete": function() {
            // this handles a bug(?) in this version of datatables;
            // hidden columns caused the table width to be set to 100px, not 100%
            $("#datatable_borrowing").css("width","100%");
        }
    });

    $('#datatable_lending').dataTable({
        "bJQueryUI": true,
        "sPaginationType": "full_numbers",
        "bInfo": true,
        "bSort": true,
        "bDestroy": true,
        "sDom": '<"H"Bfr>t<"F"ip>',
	buttons: [ 'copy', 'excel', 'pdf', 'print' ],
        "columnDefs": [
	     { "targets": 0,
               "data": null,
               "defaultContent": '<img src="'+sImageUrl+'details_open.png'+'">',
               "className": "control center"
             },
	    { "targets": 1,
              "visible": false
            }],
        "fnInitComplete": function() {
            // this handles a bug(?) in this version of datatables;
            // hidden columns caused the table width to be set to 100px, not 100%
            $("#datatable_lending").css("width","100%");
        }
    });

    $(function() {
        var dateStart = moment();
        dateStart = dateStart.subtract('months',1);
	var dateEnd = moment();
	dateEnd = dateEnd.add('days',1);

        $("#startdate").datepicker({ dateFormat: 'yy-mm-dd', defaultDate: '-1m' });
        $("#startdate").datepicker('setDate', dateStart.native() );

        $( "#enddate" ).datepicker({ dateFormat: 'yy-mm-dd', defaultDate: null });
        $(" #enddate" ).datepicker('setDate', dateEnd.native());

    });

    // From https://localhost/plugins/DataTables-1.10.2/examples/api/tabs_and_scrolling.html
    $("#tabs").tabs( {
        "activate": function(event, ui) {
            $( $.fn.dataTable.tables( true ) ).DataTable().columns.adjust();
        }
    } );
  

    $("#dateButton").on("click", function() {
        requery( $("#oid").text(), anOpenBorrowing, anOpenLending )
    });

    // Load the initial data:
    $(function() {
	requery( $("#oid").text(), anOpenBorrowing, anOpenLending );
    });
});


function requery( oid, anOpenBorrowing, anOpenLending ) 
{
    var d_s = moment( $("#startdate").datepicker("getDate") ).format("YYYY-MM-DD");
    var d_e = moment( $("#enddate").datepicker("getDate") ).format("YYYY-MM-DD");

    $("#waitDiv").show();
    $("#tabs").hide();
    $("#dateButton").prop('disabled', true);

    $.getJSON('/cgi-bin/get-history.cgi', { "oid":   oid,
                                            "start": d_s, 
                                            "end":   d_e
                                          },
              function(data){
		  $("#datatable_borrowing").DataTable().clear();
		  $("#datatable_lending").DataTable().clear();
		  build_table_borrowing( data );
		  build_table_lending( data );
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
      var sImageUrl = "/img/";
   
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

function build_table_borrowing( data ) {
    var t = $('#datatable_borrowing').DataTable();

    for (var i=0;i<data.history.borrowing.length;i++) {

	// this should match the fields in the template
	var rdata = [
	    "",
            data.history.borrowing[i].gid,
            data.history.borrowing[i].cid,
            data.history.borrowing[i].title,
            data.history.borrowing[i].author,
            data.history.borrowing[i].ts,
            data.history.borrowing[i].from,
            data.history.borrowing[i].to,
            data.history.borrowing[i].status,
            data.history.borrowing[i].message
	];
	var rowNode = t.row.add( rdata ).draw().node();
	$(rowNode).attr("id",'bc'+data.history.borrowing[i].oid);
	// the :eq selector looks at *visible* nodes....
	$(rowNode).children(":eq(4)").attr("title",data.history.borrowing[i].from_library);
	$(rowNode).children(":eq(5)").attr("title",data.history.borrowing[i].to_library);
    }
}

function build_table_lending( data ) {
    var t = $('#datatable_lending').DataTable();

    for (var i=0;i<data.history.lending.length;i++) {

	// this should match the fields in the template
	var rdata = [
	    "",
            data.history.lending[i].cid,
            data.history.lending[i].title,
            data.history.lending[i].author,
            data.history.lending[i].requested_by,
            data.history.lending[i].ts,
            data.history.lending[i].status,
            data.history.lending[i].message
	];
	var rowNode = t.row.add( rdata ).draw().node();
	$(rowNode).attr("id",'bc'+data.history.lending[i].oid);
	// the :eq selector looks at *visible* nodes....
	$(rowNode).children(":eq(3)").attr("title",data.history.lending[i].library);
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

