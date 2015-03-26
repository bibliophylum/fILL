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
$('document').ready(function(){

    $("#search").hide();
    $(".inline-items").children().hide();
    $(".inline-items").children(":contains('home')").show();

    $.getJSON('/cgi-bin/get-map-regions.cgi', 
            function(data){
                build_region_div(data);
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

    $("#registration_form").submit(function( event ) {
        if (ValidateForm()) {
            register_patron();
        }
        event.preventDefault();
    });

    $( "#reg_username" ).blur(function() {

        if ($("#reg_username").val() === undefined || $("#reg_username").val().length == 0) {
            // nothing to check yet
        } else {
            $.getJSON('/cgi-bin/check-username.cgi', { username: $("#reg_username").val() },
                function(data){
                    if (data.exists == 1) {
                        $("#username_message").text("Sorry, that username is taken.  Please try a different username.");
                        $("#username_message").stop(true,true).effect("highlight", {}, 2000);
                        $("#reg_username").focus();
                    } else {
                        $("#username_message").text("Username is unique, good!");
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
        }
    });


    $( "#password2" ).blur(function() {

        if ($("#password").val() === undefined 
           || $("#password").val().length == 0 
           || $("#password2").val() === undefined 
           || $("#password2").val().length == 0) {

            alert("Please enter a password, and then re-type the password.");
            $("#password").focus();

        } else {
            if ($("#password").val() === $("#password2").val()) {
                $("#password_message").text("Passwords match, good!");
            } else {

                $("#password_message").text("Your re-typed password did not match your origial password.  Please enter (and then re-type) a new password.");
                $("#password_message").stop(true,true).effect("highlight", {}, 2000);
                $("#password").focus();

            }
        }
    });

});

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
    for (var i=0;i<data.inregion.length;i++) {
	$('<button/>', { "id": "lid_"+data.inregion[i][0],
			 "type": "button",
			 "class": "button-left",
			 "text": data.inregion[i][1],
			 click: function() { prep_registration_form( this ); }
		       }).appendTo($("#libraries"));
	$("#lid_"+data.inregion[i][0]).data("library",data.inregion[i][2]); // library name
    }
    $("#libraries").show();
    $("#registration").hide();
}

function prep_registration_form( but ) {
    $("#home_library").text( but.innerHTML );
    $("#home_library_town").val( but.innerHTML );
    $("#home_library_name").text( $(but).data("library") );
    $("#registration").show();
    $("#patron_name").focus();
}

function register_patron() {
    // this should use lid instead of the city name stored in home_library...
    var parms = { 
	"home_library":  $("#home_library").text(),
	"patron_name":   $("#patron_name").val(),
	"patron_card":   $("#barcode").val(),
	"email_address": $("#email_address").val(),
	"username":      $("#reg_username").val(),
	"password":      $("#password").val()
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

    return true					
}


function ValidateForm(){
    //var emailID=document.registration_form.patron_email
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
    return true
}


