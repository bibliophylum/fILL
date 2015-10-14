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

/* These are very similar to patron-registration.js functions.... */

function choose_library( data ) {
    $("#region").empty();
    $("#region").append("<p>Which region of Manitoba do you live in?</p><br/>");
    for (var i=0;i<data.regions.length;i++) {
	$('<button/>', { "id": "region_"+data.regions[i][0],
			 "type": "button",
			 "class": "button-left",
			 "text": data.regions[i][0],
			 click: function() { get_libraries( this ); }
		       }).appendTo($("#region"));
    }
}

function get_libraries( but ) {
    $.getJSON('/cgi-bin/get-libraries-in-region.cgi', { region: but.innerHTML }, 
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

function build_libraries_div( data ) {
    $("#libraries").empty();
    $("#libraries").append("<p>Where is your home library?</p><br/>");
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
