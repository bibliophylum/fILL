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
