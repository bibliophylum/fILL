// internal-notes-lender.js
/*
    fILL - Free/Open-Source Interlibrary Loan management system
    Copyright (C) 2012  Government of Manitoba

    internal-notes-lender.js is a part of fILL.

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

function lenderNotes_insertChild(table, parentRow, note, childClasses) {
    if ( $.cookie('fILL-lender-internal-notes') == 'disabled' ) {
	return;
    }
    // lender internal note:
    if (note) {
	if (childClasses) { childClasses = childClasses + ' lender-note'; }
	else { childClasses = 'lender-note'; }
    } else {
	if (childClasses) { childClasses = childClasses + ' lender-note-empty'; }
	else { childClasses = 'lender-note-empty'; }
    }

    var colCount = table.columns().header().length;
    var noteLine = $('<table><tr><td class="down-right-arrow datatable-detail">\u2937</td>'
		     +'<td colspan="'+(colCount - 1)+'" class="'
		     +(childClasses ? childClasses+" edit" : "edit")+'">'
		     +(note || "Click here to add a note only visible to your staff")
		     +"</td></tr></table>");
    var row = table.row(parentRow).child( noteLine, childClasses ).show();
    $('.down-right-arrow').css({"font-weight":"bold", "text-align":"right"});
}

function lenderNotes_makeEditable() {
    if ( $.cookie('fILL-lender-internal-notes') == 'disabled' ) {
	return;
    }
    $(".edit").editable( '/cgi-bin/update-note-lender.cgi', {
	"callback": function( sValue, y ) {
	    var obj = jQuery.parseJSON( sValue );
	    this.innerHTML = obj.data;
	    $(this).removeClass("lender-note-empty");
	    $(this).addClass("lender-note");
	},
        "submitdata": function ( value, settings ) {
	    // closest tr is in the noteLine table; parent is noteLine table,
	    // closest tr to that is the DataTable child node,
	    // prev is the DataTable parent node (i.e. the DT entry with an ID)
	    return {
		"reqid": $(this).closest('tr').parent().closest('tr').prev().attr('id'),
		"private_to": $("#oid").text()
	    };
        },
	"height": "25px",
	"select": true
    });
}
