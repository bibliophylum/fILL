// login-lost-oid.js
/*
    fILL - Free/Open-Source Interlibrary Loan management system
    Copyright (C) 2012  Government of Manitoba

    login-lost-oid.js is a part of fILL.

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

// i18n.js will check if this is defined, and if so, will save the translation results
// here so we can access them dynamcially:
var i18n_data = 'data goes here';

$('document').ready(function(){

    $("#search").hide();
    $(".inline-items").children().hide();
    $(".inline-items").append('<li><a id="menu_login" class="current_tab" href="/cgi-bin/public.cgi">Welcome</a></li>');
    $(".inline-items").append('<li><a id="menu_new" href="/cgi-bin/public.cgi?rm=new_form">New to fILL?</a></li>');
    $("#menu_login").show();
    $("#menu_new").show();

    $("#fill-button").hide();  // hide the logout button, as it makes no sense here
    $("#language").hide();

    var homeLibraryOID = $.cookie("fILL-oid");
    var homeLibraryLocation = $.cookie("fILL-location");
    var patronBarcode = $.cookie("fILL-barcode");
    if (homeLibraryLocation) {
        $("#home-library-location").text( homeLibraryLocation );
        $("#home-library").show();
    }
    if (! $.cookie("fILL-oid")) {
        $.getJSON('/cgi-bin/get-map-regions.cgi', {lang: document.documentElement.lang },
            function(data){
              choose_library(data);
        });
    } else {
        if ($.cookie("fILL-authentication") === "fILL") {
            $("#extAuth").hide();
            $("#fILLAuth").show();
            $("#authen_barcode").val( "not-using-ea" );
            $("#authen_pin").val( "not-using-ea" );
            $("#authen_loginfield").focus();
	} else {
            $("#extAuth").show();
            $("#fILLAuth").hide();
            $("#authen_barcode").val( $.cookie("fILL-barcode") );
            $("#authen_loginfield").val( "using-ea" );
            $("#authen_passwordfield").val( "using-ea" );
            $("#authen_pin").focus();
	}
        $("#authen_oid").val( $.cookie("fILL-oid") );
        $("#sign-in").show();
    }

    $("#loginform").on('submit', function(e){
        e.preventDefault();

        $("#waitDiv").show();

        var myAlert = "";
        $("#loginform :input").each(function(i){
          var $input = $(this);
          myAlert += $input.attr('name')+':'+$input.val()+'\n';
        });
        //alert(myAlert);

        if ($("#authen_barcode").val()) {
            $.cookie("fILL-barcode", $("#authen_barcode").val(), { expires: 365, path: '/' });
            $.cookie("fILL-authentication", "external", { expires: 365, path: '/' });
            $("#authen_loginfield").val( "using-ea" );
            $("#authen_passwordfield").val( "using-ea" );
        } else {
            $.cookie("fILL-authentication", "fILL", { expires: 365, path: '/' });
            $("#authen_barcode").val( "not-using-ea" );
            $("#authen_pin").val( "not-using-ea" );
        }

        this.submit();
    });

    $("#nav2").append(' | </span><a href="/cgi-bin/admin.cgi">Admin</a><span style="color:#aabdba;">');
    $("#nav2").append(' | </span><a href="/cgi-bin/discovery-only.cgi">Discovery-only</a>');
    $("#nav2").append(' | </span><a href="/cgi-bin/lightning.cgi">Library Staff</a>');

});

/* These are very similar to patron-registration.js functions.... */

//----------------------------------------------------------------------------------
function choose_library( data ) {
//    $("#region").empty();
//    $("#region").append("<p>"+i18n_data['choose-region']['constant']+"</p><br/>");
    for (var i=0;i<data.regions.length;i++) {
	$('<button/>', { "id": "region_"+data.regions[i][0],
			 "type": "button",
			 "class": "button-left",
			 "text": data.regions[i][0],
			 click: function() { get_libraries( this ); }
		       }).appendTo($("#region"));
    }
    $("#region").show();
}

//----------------------------------------------------------------------------------
function get_libraries( but ) {
    $.getJSON('/cgi-bin/get-libraries-in-region.cgi', { region: but.innerHTML, lang: document.documentElement.lang }, 
            function(data){
		$("#region").hide();
		$("#selectedRegion").text( but.innerHTML );
		$("#breadcrumbs").show();
                build_libraries_div(data);
           })
        .success(function() {
            //alert('success');
        })
        .error(function(data) {
            alert('error');
        })
        .complete(function() {
            //alert('ajax complete');
        });
}

//----------------------------------------------------------------------------------
function build_libraries_div( data ) {
//    $("#libraries").empty();
//    $("#libraries").append("<p id="choose-town">Where is your home library?</p><br/>");
    for (var i=0;i<data.inregion.length;i++) {
	$('<button/>', { "id": "oid_"+data.inregion[i][0],
			 "type": "button",
			 "class": "button-left",
			 "text": data.inregion[i][1],
			 click: function() { set_cookies( this ); }
		       }).appendTo($("#libraries"));
    }
    $("#libraries").show();
}

//----------------------------------------------------------------------------------
function set_cookies( but ) {
    $("#libraries").hide();
    $("#selectedLibrary").text( but.innerHTML );
    $.getJSON('/cgi-bin/check-library-authentication-method.cgi', { city: but.innerHTML }, 
            function(data){
		if (data.ea.enabled === 1) {
		    $.cookie("fILL-authentication", 
			     "external",
			     { expires: 365, path: '/' });
		    $("#login_text").text( data.ea.login_text );
		    $("label[for = authen_barcode]").text( data.ea.barcode_label_text );
		    $("label[for = authen_pin]").text( data.ea.pin_label_text );
		    $("#extAuth").show();
		    $("#fILLAuth").hide();

		} else {
		    $.cookie("fILL-authentication", "fILL", { expires: 365, path: '/' });
		    $("#extAuth").hide();
		    $("#fILLAuth").show();
		    // no need for signup if everyone authenticates via their library ILS...
		    //$("#signup").show();  
		}
		$("#oid").val( data.ea.oid );
                $("#authen_oid").val( data.ea.oid );
		$.cookie("fILL-location", but.innerHTML, { expires: 365, path: '/' });
		$.cookie("fILL-oid", data.ea.oid, { expires: 365, path: '/' });

		if ($.cookie("fILL-authentication") === "fILL") {	
                    $("#extAuth").hide();
                    $("#fILLAuth").show();
                    $("#authen_barcode").val( "not-using-ea" );
                    $("#authen_pin").val( "not-using-ea" );
                    $("#authen_loginfield").focus();
		} else {
                    $("#extAuth").show();
                    $("#fILLAuth").hide();
                    $("#authen_barcode").val( $.cookie("fILL-barcode") );
                    $("#authen_loginfield").val( "using-ea" );
                    $("#authen_passwordfield").val( "using-ea" );
                    $("#authen_barcode").focus();
		}
                $("#sign-in").show();
           })
        .success(function() {
            //alert('success');
        })
        .error(function(data) {
            alert('error');
        })
        .complete(function() {
            //alert('ajax complete');
        });
}
