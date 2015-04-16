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
    
    set_primary_tab("menu_authentication");
    
    $("#scrolling-table").slimScroll({
	height: '500px',
	alwaysVisible: true,
	railVisible: true,
	wheelStep: 1,
	allowPageScroll: false,
	disableFadeOut: false,
	scrollBy: '10px'
    });
    

    $(".action-button").on("click",function(){
	//alert($(this).closest('tr').attr('id'));
	$("#waitDiv").show();
	$.getJSON('/cgi-bin/get-authentication-info.cgi', 
		  { lid: $(this).closest('tr').attr('id') },
		  function(data){
		      $("#initialMessage").hide();
		      $("#library-name").text( data.library.library );
		      $("#auth-common").show();

		      if (data.sip2) {
			  if (data.sip2.enabled) {
			      $('input:radio[name=sipEnabled]')[0].checked = true;
			  } else {
			      $('input:radio[name=sipEnabled]')[1].checked = true;
			  }
			  $("#sipHost").val( data.sip2.host );
			  $("#sipPort").val( data.sip2.port );
			  if (data.sip2.terminator) {
			      $('input:radio[name=sipTerminator]')[1].checked = true;
			  } else {
			      $('input:radio[name=sipTerminator]')[0].checked = true;
			  }
			  $("#sipServerLogin").val( data.sip2.sip_server_login );
			  $("#sipServerPass").val( data.sip2.sip_server_pass );
			  if ( data.sip2.validate_using_info ) {
			      $('input:radio[name=sipMethod]')[1].checked = true;
			  } else {
			      $('input:radio[name=sipMethod]')[0].checked = true;
			  }
			  $("#auth-none").hide();
			  $("#auth-sip2").show();
			  $("#auth-other").hide();

		      } else if (data.nonsip2) {
			  if (data.nonsip2.enabled) {
			      $('input:radio[name=nonsipEnabled]')[0].checked = true;
			      $('input:radio[name=nonsipEnabled]')[1].checked = false;
			  } else {
			      $('input:radio[name=nonsipEnabled]')[0].checked = false;
			      $('input:radio[name=nonsipEnabled]')[1].checked = true;
			  }
			  if (data.nonsip2.auth_type === "Biblionet") {
			      $('input:radio[name=nonsipAuthType]')[0].checked = true;
			  } else if (data.nonsip2.auth_type === "FollettDestiny") {
			      $('input:radio[name=nonsipAuthType]')[1].checked = true;
			  } else {
			      $('input:radio[name=nonsipAuthType]')[2].checked = true;
			  }
			  $("#nonsipURL").val( data.nonsip2.url );

			  $("#auth-none").hide();
			  $("#auth-sip2").hide();
			  $("#auth-other").show();
		      } else {
			  $("#auth-none").show();
			  $("#auth-sip2").hide();
			  $("#auth-other").hide();
		      }

		      $("#waitDiv").hide();
		  });
    });

});
