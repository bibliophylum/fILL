// patron-registration.js
/*
    fILL - Free/Open-Source Interlibrary Loan management system
    Copyright (C) 2012  Government of Manitoba

    patron-registration.js is a part of fILL.

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
function build_region_div( data ) {
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
    $("#waitDiv").toggle();
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
    for (var i=0;i<data.city.length;i++) {
	$('<button/>', { "id": "city_"+data.city[i][0],
			 "type": "button",
			 "class": "button-left",
			 "text": data.city[i][0],
			 click: function() { prep_registration_form( this ); }
		       }).appendTo($("#libraries"));
    }
    $("#libraries").show();
    $("#registration").hide();
}

function prep_registration_form( but ) {
    $.getJSON('/cgi-bin/check-library-sip2-support.cgi', { city: but.innerHTML }, 
            function(data){
                if (data.sip2.enabled === 1) {
		    $("#lid").val( data.sip2.lid );
		    $("#sip2").show();
		    $("#non-sip2").hide();
		    $.cookie("fILL-lid", data.sip2.lid);
		    $.cookie("fILL-location", but.innerHTML);
		    $.cookie("fILL-authentication", "sip2");
		} else {
		    $("#sip2").hide();
		    $("#non-sip2").show();
		}
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
    $("#home_library").text( but.innerHTML );
    $("#home_library_town").val( but.innerHTML );
    $("#registration").show();
    if ( $("#patron_name").is(":visible") ) {
	$("#patron_name").focus();
    } else {
	$("#barcode").focus();
    }
}

function register_patron() {
    var parms = { 
	"home_library":  $("#home_library").text(),
	"patron_name":   $("#patron_name").val(),
	"patron_card":   $("#barcode").val(),
	"email_address": $("#email_address").val(),
	"username":      $("#reg_username").val(),
	"password":      $("#password").val(),
	"sip2_enabled":  $("#sip2-enabled").val()
    };
    $.getJSON('/cgi-bin/register-patron.cgi', parms,
              function(data){
		  $("#complete").empty();
		  if (data.success === 0) {
		      $("#complete").append("<h3>There was a problem creating your account.</h3><p>Please contact your local library.</p>");
		  } else {
		      $("#complete").append("<h3>Your account has been created.</h3>");
		      $("input").prop('disabled', true);
		      $("#submitRegistration").hide();
//		      $("#complete").append('<button><a href="/cgi-bin/public.cgi">Log in to fILL</a></button>');
		      $("#complete").append('<a id="fill-button" role="button" type="button" href="/cgi-bin/public.cgi">Log in to fILL</a>');
		  }
		  $("#complete").show();
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

function register_sip2_patron() {
    var parms = { 
	"lid":           $("#lid").val(),
	"patron_card":   $("#barcode").val(),
//	"patron_pin":    $("#pin").val(),
	"patron_name":   $("#sip2_patron_name").text()
    };
    $.getJSON('/cgi-bin/register-sip2-patron.cgi', parms,
              function(data){
		  $("#complete").empty();
		  if (data.success === 0) {
		      $("#complete").append("<h3>There was a problem creating your account.</h3><p>Please contact your local library.</p>");
		  } else {
		      $("#complete").append("<h3>Your account has been created.</h3>");
		      $("input").prop('disabled', true);
		      $("#submitSIP2Registration").hide();
		      $("#complete").append('<a id="fill-button" role="button" type="button" href="/cgi-bin/public.cgi">Log in to fILL</a>');
		      $.cookie("fILL-barcode", $("#barcode").val());
		  }
		  $("#complete").show();
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

/**
 * DHTML email validation script. Courtesy of SmartWebby.com (http://www.smartwebby.com/dhtml/)
 */

function echeck(str) {

    var at="@"
    var dot="."
    var lat=str.indexOf(at)
    var lstr=str.length
    var ldot=str.indexOf(dot)
    if (str.indexOf(at)==-1){
       alert("Invalid E-mail ID")
       return false
    }

    if (str.indexOf(at)==-1 || str.indexOf(at)==0 || str.indexOf(at)==lstr){
       alert("Invalid E-mail ID")
       return false
    }

    if (str.indexOf(dot)==-1 || str.indexOf(dot)==0 || str.indexOf(dot)==lstr){
        alert("Invalid E-mail ID")
        return false
    }

    if (str.indexOf(at,(lat+1))!=-1){
        alert("Invalid E-mail ID")
        return false
    }

    if (str.substring(lat-1,lat)==dot || str.substring(lat+1,lat+2)==dot){
        alert("Invalid E-mail ID")
        return false
    }

    if (str.indexOf(dot,(lat+2))==-1){
        alert("Invalid E-mail ID")
        return false
    }

    if (str.indexOf(" ")!=-1){
        alert("Invalid E-mail ID")
        return false
    }

    return true;					
}


function ValidateForm(){
    var emailID=$("#email_address");

    if ((emailID.val()==null)||(emailID.val()=="")){
        alert("Please enter your email address");
        emailID.focus();
        return false;
    }
    if (echeck(emailID.val())==false){
        emailID.val("");
        emailID.focus();
        return false;
    }
    if ($("#reg_username").val() === undefined || $("#reg_username").val().length == 0) {
	alert("Please choose a user name for your account.");
	$("#reg_username").focus();
	return false;
    }
    return true;
}


function ValidateSIP2Form(){
    if (( $("#barcode").val()==null)||( $("#barcode").val()=="")){
        alert("Please enter your library card number");
        $("#barcode").focus();
        return false;
    }
    if (( $("#pin").val()==null)||( $("#pin").val()=="")){
        alert("Please enter your library PIN number");
        $("#pin").focus();
        return false;
    }

    return true;
}

function sip2_authenticate_and_register() {
    var parms = { 
	"lid":     $("#lid").val(),
	"barcode": $("#barcode").val(),
	"pin":     $("#pin").val(),
    };
    
    $.getJSON('/cgi-bin/sip2-authenticate.cgi', parms,
              function(data){
              })
        .success(function(data) {
            //alert('success');
      	    if (( data.authorized.screenmessage ) && ( data.authorized.screenmessage != 'null' )){
      		$("#msgFromLibrarySystem").text( data.authorized.screenmessage );
	    }
	    if ( data.authorized.validbarcode === 'Y' ) {
		if ( data.authorized.validpin === 'Y' ) {
		    $("#sip2_patron_name").text( data.authorized.patronname );
                    register_sip2_patron();
		} else {
		    alert("The PIN number you entered does not match your library's record.");
		    $("#pin").focus();
		}
	    } else {
		alert("The barcode you entered does not exist at your library.");
		$("#barcode").focus();
	    }
        })
        .error(function(data) {
            alert('error');
        })
        .complete(function() {
            //alert('ajax complete');
        });

}
