// internal-notes-new-patron-requests.js
/*
    fILL - Free/Open-Source Interlibrary Loan management system
    Copyright (C) 2012  Government of Manitoba

    internal-notes-borrower.js is a part of fILL.

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

function nprNotes_insertChild(table, parentRow, note, childClasses) {
    if ( $.cookie('fILL-borrower-internal-notes') == 'disabled' ) {
	return;
    }
    // borrower internal note:
    if (note) {
	if (childClasses) { childClasses = childClasses + ' npr-note'; }
	else { childClasses = 'npr-note'; }
    } else {
	if (childClasses) { childClasses = childClasses + ' npr-note-empty'; }
	else { childClasses = 'npr-note-empty'; }
    }

    var colCount = table.columns().header().length;
    var noteLine = $('<tr><td class="down-right-arrow datatable-detail">\u2937</td>'
		     +'<td colspan="'+(colCount - 1)+'" class="'
		     +(childClasses ? childClasses+" edit" : "edit")+'">'
		     +(note || "Click here to add a note only visible to your staff")
		     +"</td></tr>")[0]; // IE doesn't like .child() having a jQ parm.
    table.row(parentRow).child( noteLine, childClasses ).show();
    $('.down-right-arrow').css({"font-weight":"bold", "text-align":"right"});
}

function nprNotes_makeEditable() {
    if ( $.cookie('fILL-borrower-internal-notes') == 'disabled' ) {
	return;
    }
    $(".edit").editable( '/cgi-bin/update-note-new-patron-request.cgi', {
	"callback": function( sValue, y ) {
	    var obj = jQuery.parseJSON( sValue );
	    if (obj.data == "") {
		this.innerHTML = "Click here to add a note only visible to your staff";
		$(this).removeClass("npr-note");
		$(this).addClass("npr-note-empty");
	    } else {
		this.innerHTML = obj.data;
		$(this).removeClass("npr-note-empty");
		$(this).addClass("npr-note");
	    }
	},
        "submitdata": function ( value, settings ) {
	    return {
		"prid": $(this).closest('tr').prev().attr('id'),
		"private_to": $("#oid").text()
	    };
        },
	"height": "25px",
	"select": true
    });
}
