// rotation-item-circ-counts.js
/*
    fILL - Free/Open-Source Interlibrary Loan management system
    Copyright (C) 2012  Government of Manitoba

    rotation-item-circ-counts.js is a part of fILL.

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

    set_secondary_tab("menu_rotations_report_item_circ_counts");

    $('#item-circ-counts-table').DataTable({
        "jQueryUI": true,
        "pagingType": "full_numbers",
        "info": true,
        "ordering": true,
        "dom": '<"H"Bfr>t<"F"ip>',
        buttons: [ 'copy', 'excel', 'pdf', 'print' ],
        "initComplete": function() {
            // this handles a bug(?) in this version of datatables;
            // hidden columns caused the table width to be set to 100px, not 100%
            $("#item-circ-counts-table").css("width","100%");
	    
	    //$("#item-circ-counts-table").DataTable().page.len( parseInt($("#table_rows_per_page").text(),10));
        }
    });

    $(function() {
        var dateStart = moment();
        dateStart = dateStart.subtract('months',1);
	var dateEnd = moment();
	dateEnd = dateEnd.add('days',1);

        $("#startdate").datepicker({ dateFormat: 'yy-mm-dd', defaultDate: '-3m' });
        $("#startdate").datepicker('setDate', dateStart.native() );

        $( "#enddate" ).datepicker({ dateFormat: 'yy-mm-dd', defaultDate: null });
        $(" #enddate" ).datepicker('setDate', dateEnd.native());

    });

    $("#dateButton").on("click", function() {
	requery( $("#oid").text() );
    });
    
    // Load the initial data:
    $(function() {
	requery( $("#oid").text() );
    });

});

function requery( oid ) {
    var d_s = moment( $("#startdate").datepicker("getDate") ).format("YYYY-MM-DD");
    var d_e = moment( $("#enddate").datepicker("getDate") ).format("YYYY-MM-DD");

    $("#waitDiv").show();
    $("#dateButton").prop('disabled', true);
    
    $.getJSON('/cgi-bin/get-rotations-item-circ-counts.cgi', {"oid": oid,
							      "start": d_s, 
							      "end":   d_e
							     },
              function(data){
		  $("#item-circ-counts-table").DataTable().clear();
		  build_table(data);
		  $("#waitDiv").hide();
		  $("#mylistDiv").show();
              })
	.success(function() {
	    $("#waitDiv").hide();
	    $("#dateButton").prop('disabled', false);
        })
	.error(function() {
        })
	.complete(function() { 
        });
};

function build_table( data ) {
    var t = $('#item-circ-counts-table').DataTable();
    
    for (var i=0;i<data.rotations_item_circ_counts.length;i++) {

	//var divResponses = create_action_buttons( data, i );

	// this should match the fields in the template
	var rdata = [
	    data.rotations_item_circ_counts[i].library,
	    data.rotations_item_circ_counts[i].symbol,
	    data.rotations_item_circ_counts[i].ts_start,
	    data.rotations_item_circ_counts[i].ts_end,
	    data.rotations_item_circ_counts[i].title,
	    data.rotations_item_circ_counts[i].callno,
	    data.rotations_item_circ_counts[i].barcode,
	    data.rotations_item_circ_counts[i].circs
	];
	var rowNode = t.row.add( rdata ).draw().node();
//	$(rowNode).attr("id",'req'+data.rotations_item_circ_counts[i].id);
	// the :eq selector looks at *visible* nodes....
//	$(rowNode).children(":eq(0)").attr("title",data.rotations_item_circ_counts[i].library);
//	$(rowNode).children(":last").append( divResponses );
    }
}

