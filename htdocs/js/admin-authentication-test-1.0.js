// admin-authetication.js
/*
    fILL - Free/Open-Source Interlibrary Loan management system
    Copyright (C) 2012  Government of Manitoba

    admin-authentication is a part of fILL.

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
    
    set_primary_tab("menu_authentication_tests");
//    $("#form-buttons").hide();
    $("#waitDiv-testing").hide();
    $("#test-results").hide();
    $("#no-data").hide();
    $("#test-user").hide();

    $(".action-button").on("click",function(){
	//alert($(this).closest('tr').attr('id'));
	$("#waitDiv").show();
	$("#editOID").val( $(this).closest('tr').attr('id') );
	$.getJSON('/cgi-bin/admin-get-authentication-test-patron.cgi', 
		  { oid: $(this).closest('tr').attr('id') },
		  function(data){
		      $("#initialMessage").hide();
		      $("#test-results").hide();

		      if (!data.tp) {
			  $("#test-user").hide();
			  $("#no-data").show();
		      } else {
			  $("#test-user").show();
			  $("#no-data").hide();

			  $("#library-name").val( data.tp.org_name );
			  $("#selected-oid").val( data.tp.oid );
			  $("#test_patron_auth_method").val( data.tp.patron_authentication_method );
			  $("#test_patron_last_tested").val( data.tp.last_tested );
			  $("#my_test_patron_barcode").val( data.tp.barcode );
			  $("#my_test_patron_pin").val( data.tp.pin );
			  $("#test_patron_test_result").val( data.tp.pin );
		      }

		      $("#waitDiv").hide();
		  });
    });

    
    $("#testPatronButton").on("click", function() {
	$("#testPatronButton").hide();
	$("#waitDiv-testing").show();
	var parms = {
	    "oid": $("#selected-oid").val(),
	};
	$.getJSON('/cgi-bin/test-authentication.cgi', parms,
		  function(data){
		  })
	    .success(function(data) {
		//alert('success');
		$("#test_patron_last_tested").val( data.result.lasttested );
		$("#test_patron_test_result").val( data.result.status );
		$("#test_patron_validbarcode").val( data.result.validbarcode );
		$("#test_patron_validpin").val( data.result.validpin );
		$("#test_patron_patronname").val( data.result.patronname );
		$("#test_patron_screenmessage").val( data.result.screenmessage );
		$("#test_patron_auth_method").val( data.result.authentication_method );
		$("#test-results").show();
	    })
	    .error(function() {
		alert('error');
	    })
	    .complete(function() {
		//alert('ajax complete');
		$("#waitDiv-testing").hide();
		$("#testPatronButton").show();
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
