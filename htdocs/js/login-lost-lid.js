// login-lost-lid.js
/*
    fILL - Free/Open-Source Interlibrary Loan management system
    Copyright (C) 2012  Government of Manitoba

    login-lost-lid.js is a part of fILL.

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
	$('<button/>', { "id": "lid_"+data.inregion[i][0],
			 "type": "button",
			 "class": "button-left",
			 "text": data.inregion[i][1],
			 click: function() { set_cookies( this ); }
		       }).appendTo($("#libraries"));
    }
    $("#libraries").show();
}

function set_cookies( but ) {
    $.getJSON('/cgi-bin/check-library-sip2-support.cgi', { city: but.innerHTML }, 
            function(data){
                if (data.sip2.enabled === 1) {
		    $.cookie("fILL-authentication", "sip2", { expires: 365, path: '/' });
		    $("#sip2").show();
		    $("#non-sip2").hide();

		} else {
		    $.cookie("fILL-authentication", "fILL", { expires: 365, path: '/' });
		    $("#sip2").hide();
		    $("#non-sip2").show();
		}
		$("#lid").val( data.sip2.lid );
                $("#authen_lid").val( data.sip2.lid );
		$.cookie("fILL-location", but.innerHTML, { expires: 365, path: '/' });
		$.cookie("fILL-lid", data.sip2.lid, { expires: 365, path: '/' });

		if ($.cookie("fILL-authentication") === "sip2") {
                    $("#sip2").show();
                    $("#non-sip2").hide();
                    $("#authen_barcode").val( $.cookie("fILL-barcode") );
                    $("#authen_loginfield").val( "using-sip2" );
                    $("#authen_passwordfield").val( "using-sip2" );
                    $("#authen_pin").focus();
		} else {
                    $("#sip2").hide();
                    $("#non-sip2").show();
                    $("#authen_barcode").val( "not-using-sip2" );
                    $("#authen_pin").val( "not-using-sip2" );
                    $("#authen_loginfield").focus();
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
