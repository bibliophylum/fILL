// rotations.js
/*
    fILL - Free/Open-Source Interlibrary Loan management system
    Copyright (C) 2012  Government of Manitoba

    rotations.js is a part of fILL.

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

  $("circCount").hide();

  oTable = $('#datatable_scanned').DataTable({
      "bJQueryUI": true,
      "sPaginationType": "full_numbers",
      "bInfo": true,
      "bSort": true,
      "dom": '<"H"Bfr>t<"F"ip>',
      buttons: [ 'copy', 'excel', 'pdf', 'print' ],
      "columnDefs": [{
	  "targets": 0,
	  "visible": false
      }],
      "order": [[ 7, "desc" ]]
  });

  $("#barcode").on("change", function() {
    barcode_scanned(this.value); 
    this.value=''; 
    this.focus(); 
  });

  // some users are reporting that the scanned barcode doesn't
  // automatically appear in the data table (i.e. that the onChange
  // wasn't firing.  So let's add a manual option:
  $("#scanOk").on("click", function() {
    // button does nothing except change focus from text input,
    // which triggers onChange.
    $("#barcode").focus();
    return false;
  });


  // start with focus on barcode field
  $("#barcode").focus();

});

function barcode_scanned( bc ) {
  if ( $("#oid").text() == 101 ) {
      $("#circCount").hide();
  }
  $.getJSON('/cgi-bin/rotation-item-scanned.cgi', {oid: $("#oid").text(), barcode: bc },
    function(data){
        if ( $("#oid").text() == "101" ) {  // I hate magic.
	    $("#circCount").text("Total circulation: "+data.circs);
	    if (data.circs == 0) {
	        $("#circCount").css("background-color","#f78181");
            } else {
	        $("#circCount").css("background-color","#ffffff");
            }
            $("#circCount").show();

	    $("#circHistory").empty(); // get rid of old table
	    var histTable = "<table><thead><tr><th>Library</th><th>Arrived</th><th>Circs</th></tr></thead><tbody>";
	    for (var i=0;i<data.history.length;i++) {
		histTable += "<tr><td>"+data.history[i].org_name+"</td><td>"+data.history[i].arrived+'</td><td align="right">'+data.history[i].circs+"</td></tr>";
	    }
	    histTable += "</tbody></table>";
	    $("#circHistory").append(histTable);
        }
        add_row_to_table(data);
    }
  );
};

function downloadMarc() {
  $.getJSON('/cgi-bin/rotations-MARC-file.cgi', {oid: $("#oid").text() },
    function(data){
	// alert(data.filename);
	window.open( '/rotations-MARC/' );
        }
  );
}


function add_row_to_table_DEPRECATED( data ) {
    for (var i=0;i<data.item.length;i++) {
        var ai = oTable.fnAddData( data.item[i] );
        var n = oTable.fnSettings().aoData[ ai[0] ].nTr;
        var oData = oTable.fnGetData( n );
        n.setAttribute('id', n.cells[0].innerHTML);

    }
}

function add_row_to_table( data ) {
    var t = $("#datatable_scanned").DataTable();
    for (var i=0;i<data.item.length;i++) {
	var $added_row = t.row.add( [
	    data.item[i].id,
	    data.item[i].barcode,
	    data.item[i].callno,
	    data.item[i].title,
	    data.item[i].author,
	    data.item[i].current_library,
	    data.item[i].previous_library,
	    data.item[i].timestamp
        ] ).draw().node();
	$($added_row).prop('id', data.item[i].id);
    }
}
