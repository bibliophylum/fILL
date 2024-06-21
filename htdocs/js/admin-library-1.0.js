// admin-library.js
/*
    fILL - Free/Open-Source Interlibrary Loan management system
    Copyright (C) 2012  Government of Manitoba

    admin-library is a part of fILL.

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

$('document').ready(function() {

    // Most primary tabs are set as the current tab in the submenu_xxxxx.
    // admin menu doesn't have a submenu, so we set the current tab here.
    
    set_primary_tab("menu_library_pw");
    $("#form-buttons").hide();

/*    
    $("#scrolling-table").slimScroll({
	height: '500px',
	alwaysVisible: true,
	railVisible: true,
	wheelStep: 1,
	allowPageScroll: false,
	disableFadeOut: false,
	scrollBy: '10px'
    });
*/    
/*
    $('input').on("change",function(){
	$("#form-buttons").show();
    });
*/
    $(".action-button").on("click",function(){
	//alert($(this).closest('tr').attr('id'));
	$("#waitDiv").show();
	
	$("#editUID").val( $(this).closest('tr').attr('id') );
	$("#initialMessage").hide();	
	$("#library-name").text( $(this).closest('tr').find(':nth-child(1)').text() );
	$("#library-user").text( $(this).closest('tr').find(':nth-child(3)').text() );
	$("#library-user-edit").show();
	$("#form-buttons").show();

	$("#waitDiv").hide();
    });

    
    $("#save-btn").on("click",function(e){
//    $("#editAuthentication").on("submit",function(e){
	e.stopPropagation();
	var $myForm=$("#editUser");
	var parms = $myForm.serialize();
	$.getJSON('/cgi-bin/admin-update-library.cgi', 
		  parms,
		  function(data){
		      //alert("returned from ajax call");
		  })
	    .success(function( data ) {
		alert("Library staff user updated.");
		$("#form-buttons").hide();
		$("#library-user-edit").hide();
		$("#initialMessage").show();	
	    })
	    .error(function( data ) {
		alert( data.error_message );
	    })
	    .complete(function() {
	    });
    });

    
    $("#libraries").DataTable({
        "jQueryUI": true,
        "pagingType": "full_numbers",
        "info": true,
        "ordering": true,
        "dom": '<"H"fr>t<"F"ip>',
        "pageLength": 10,
        "lengthMenu": [[10, 25, 50, -1], [10, 25, 50, "All"]],
	"autoWidth": true,
        "initComplete": function() {
            // this handles a bug(?) in this version of datatables;
            // hidden columns caused the table width to be set to 100px, not 100%
            $("#libraries").css("width","100%");
	    $("#libraries_filter").addClass("pull-left");
        }
    });
    
});
