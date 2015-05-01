// admin-pazpar.js
/*
    fILL - Free/Open-Source Interlibrary Loan management system
    Copyright (C) 2012  Government of Manitoba

    admin-pazpar is a part of fILL.

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
    // welcome menu doesn't have a submenu, so we set the current tab here.
    //
    //set_primary_tab("menu_zserver");
    set_secondary_tab("menu_zserver_pazpar_control");

    $("#zserver").hide();
    $("#writexml").hide();

    var selected_zServer;

    $("#formSubmit").on('click', function(e){
	e.preventDefault();
	//alert("Submit clicked.");
	var parms = {
	    "lid": $("#editLID").val(),
	    "all": false
	};
	//alert("parms:" + parms);
	$.getJSON('/cgi-bin/admin-pazpar-writexml.cgi', parms,
		  function(data){
		  })
	    .success(function() {
		// alert('success');
	    })
	    .error(function(data) {
		alert('error');
	    })
	    .complete(function() {
	    });
	$("#edit").hide();
	$("#myDiv").show();
	window.location.hash = '#myDiv';
    });
    
    $(".action-button").on("click",function(){
	$("#choose").hide();
	$("#libtowrite").text( $(this).val() );
	$("#chosen").show();
	selected_zserver = $(this).val();
	$.getJSON('/cgi-bin/admin-get-z3950settings.cgi', { libsym: $(this).val() },
		  function(data){
		  })
	    .done(function(data) {
		$("#server").val( data.data[0].server_address );
		$("#port").val( data.data[0].server_port );
		$("#database").val( data.data[0].database_name );
		$("#zserver").show();
		$("#writexml").show();
	    })
	    .fail(function() {
		//alert('error testing zServer!');
	    })
	    .always(function() {
		//alert('ajax complete');
	    });
    });

    $("#all-zservers").on("click",function(){
	selected_zserver = "ALL";
	$("#choose").hide();
	$("#libtowrite").text( "ALL zServers selected." );
	$("#chosen").show();
	$("#writexml").show();
    });

    $("#writexmlbtn").on("click",function(){
	$.getJSON('/cgi-bin/admin-pazpar2-write-xml.cgi', { libsym: selected_zserver },
		  function(data){
		  })
	    .done(function(data) {
		alert('.xml write done!');
		$("#zserver").hide();
		$("#writexml").hide();
		$("#chosen").hide();
		$("#choose").show();
	    })
	    .fail(function() {
		alert('error writing zServer .xml!');
	    })
	    .always(function() {
		//alert('ajax complete');
	    });
    });

    $("#restart-pazpar").on("click",function(){
	$.getJSON('/cgi-bin/admin-pazpar2-restart.cgi', {},
		  function(data){
		  })
	    .done(function(data) {
		alert('Pazpar2 system restart has been queued.');
		$("#zserver").hide();
		$("#writexml").hide();
		$("#chosen").hide();
		$("#choose").show();
	    })
	    .fail(function() {
		alert('error restarting pazpar2 system.');
	    })
	    .always(function() {
		//alert('ajax complete');
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
