// admin-z3950-check.js
/*
    fILL - Free/Open-Source Interlibrary Loan management system
    Copyright (C) 2012  Government of Manitoba

    admin-z3950-check is a part of fILL.

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
    set_secondary_tab("menu_zserver_test");
    
    $(".zstatus").hide();
    $("#waitDiv").hide();
    
    $(".action-button").on("click",function(){
	$("#libtotest").text( $(this).val() );
	$("#waitDiv").show();
	$(".zstatus").hide();
	$.getJSON('/cgi-bin/check-zserver-connectivity.cgi', { libsym: $(this).val(), log: 1 },
		  function(data){
		      $(".zstatus").show();
		      $("#zPresent").attr("class","zno");
		      $("#zPresent").text("No "+String.fromCharCode(10007));
		      if (data.success == 1) {
			  $("#zPresent").attr("class","zyes");
			  $("#zPresent").text("Yes "+String.fromCharCode(10004));
		      }
		      
		      $("#zConnect").attr("class","zno");
		      $("#zConnect").text("No "+String.fromCharCode(10007));
		      if (data.zServer_status.connection != null) {
			  if (data.zServer_status.connection.success != null) {
			      if (data.zServer_status.connection.success == 1) {
				  $("#zConnect").attr("class","zyes");
				  $("#zConnect").text("Yes "+String.fromCharCode(10004));
			      }
			  }
		      }
		      
		      $("#zSearch").attr("class","zno");
		      $("#zSearch").text("No "+String.fromCharCode(10007));
		      if (data.zServer_status.search != null) {
			  if (data.zServer_status.search.success != null) {
			      if (data.zServer_status.search.success == 1) {
				  $("#zSearch").attr("class","zyes");
				  $("#zSearch").text("Yes "+String.fromCharCode(10004));
			      }
			  }
		      }
		      
		      $("#zRecord").attr("class","zno");
		      $("#zRecord").text("No "+String.fromCharCode(10007));
		      if (data.zServer_status.record != null) {
			  if (data.zServer_status.record.success != null) {
			      if (data.zServer_status.record.success == 1) {
				  $("#zRecord").attr("class","zyes");
				  $("#zRecord").text("Yes "+String.fromCharCode(10004));
			      }
			  }
		      }
		      
		      //data.log = data.log.replace(/\n/g,"<br />");
		      $("#log").text( data.log );
		  })
	    .done(function() {
		//alert('success!\n'+data);
	    })
	    .fail(function() {
		//alert('error testing zServer!');
	    })
	    .always(function() {
		//alert('ajax complete');
		$("#waitDiv").hide();
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
