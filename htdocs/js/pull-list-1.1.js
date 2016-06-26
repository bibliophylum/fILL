// pull-list.js
/*
    fILL - Free/Open-Source Interlibrary Loan management system
    Copyright (C) 2012  Government of Manitoba

    pull-list.js is a part of fILL.

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

    set_secondary_tab("menu_lend_pull");
    
    $('#pull-list').DataTable({
	"jQueryUI": true,
	"pagingType": "full_numbers",
	"info": true,
	"ordering": true,
	"dom": '<"H"Bfr>t<"F"ip>',
	buttons: [ 'copy', 'excel', 'pdf', 'print' ],
	"initComplete": function() {
            // this handles a bug(?) in this version of datatables;
            // hidden columns caused the table width to be set to 100px, not 100%
            $("#pull-list").css("width","100%");

	    $("#pull-list").DataTable().page.len( parseInt($("#table_rows_per_page").text(),10));
	}
    });

    $.getJSON('/cgi-bin/get-pull-list.cgi', {oid: $("#oid").text()},
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
    var t = $('#pull-list').DataTable();
    
    for (var i=0;i<data.pullList.length;i++) {

	// this should match the fields in the template
	var rdata = [
	    data.pullList[i].call_number,
	    data.pullList[i].author,
	    data.pullList[i].title,
	    data.pullList[i].ts,
	    data.pullList[i].from,
	    data.pullList[i].note,
	    data.pullList[i].pubdate,
	    data.pullList[i].barcode+'<br/>'
		+'<img alt="barcode image" src="data:image/png;base64,'
		+data.pullList[i].barcode_image
		+'">'
	];
	var rowNode = t.row.add( rdata ).draw().node();
//	$(rowNode).attr("id",'req'+data.pullList[i].id);
	// the :eq selector looks at *visible* nodes....
	$(rowNode).children(":eq(4)").attr("title",data.pullList[i].library);
    }
}

