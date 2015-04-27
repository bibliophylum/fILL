// account-settings.js
/*
    fILL - Free/Open-Source Interlibrary Loan management system
    Copyright (C) 2012  Government of Manitoba

    account-settings.js is a part of fILL.

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

    $("#contactButton").hide();
    $("#mailingButton").hide();
    $("#z3950Button").hide();
    $("#otherButton").hide();

    $("#tabs").tabs();
    $("#tabs").show();

    $("div.balanced-fields div label").autoWidth();

    $("#contact_information_fieldset input").on("change",function(){
	$("#contactButton").show();
    });
    $("#mailing_information_fieldset input").on("change",function(){
	$("#mailingButton").show();
    });
    $("#z3950_fieldset input").on("change",function(){
	$("#z3950Button").show();
    });
    $("#otherForm input").on("change",function(){
	$("#otherButton").show();
    });

    $("#contactButton").on("click", function() {
	var parms = {
	    "lid": $("#lid").text(),
	    "email_address": $("#email_address").val(),
	    "website": $("#website").val(),
	};
	$.getJSON('/cgi-bin/update-library-settings-contact.cgi', parms,
		  function(data){
		      //alert(data);
		  })
	    .success(function() {
		//alert('success');
		$("#contactButton").hide();
	    })
	    .error(function() {
		alert('error');
	    })
	    .complete(function() {
		//alert('ajax complete');
	    });
    });


    $("#mailingButton").on("click", function() {
	var parms = {
	    "lid": $("#lid").text(),
	    "library": $("#library").val(),
	    "mailing_address_line1": $("#mailing_address_line1").val(),
	    "city": $("#city").val(),
	    "province": $("#province").val(),
	    "post_code": $("#post_code").val()
	};
	$.getJSON('/cgi-bin/update-library-settings-mailing.cgi', parms,
		  function(data){
		  })
	    .success(function() {
		//alert('success');
		$("#mailingButton").hide();
	    })
	    .error(function() {
		alert('error');
	    })
	    .complete(function() {
		//alert('ajax complete');
	    });
    });


    $("#z3950Button").on("click", function() {
	var parms = {
	    "lid": $("#lid").text(),
	    "z3950_server_address": $("#z3950_server_address").val(),
	    "z3950_server_port": $("#z3950_server_port").val(),
	    "z3950_database_name": $("#z3950_database_name").val(),
	};
	$.getJSON('/cgi-bin/update-library-settings-z3950.cgi', parms,
		  function(data){
		  })
	    .success(function() {
		//alert('success');
		$("#z3950Button").hide();
	    })
	    .error(function() {
		alert('error');
	    })
	    .complete(function() {
		//alert('ajax complete');
	    });
    });


    $("#otherButton").on("click", function() {
	var parms = {
	    "lid": $("#lid").text(),
	    "slips_with_barcodes": $('input[name=slips_with_barcodes]:checked', '#otherForm').val(),
	    "centralized_ill": $('input[name=centralized_ill]:checked', '#otherForm').val()
	};
	$.getJSON('/cgi-bin/update-library-settings-other.cgi', parms,
		  function(data){
		  })
	    .success(function() {
		//alert('success');
		$("#otherButton").hide();
	    })
	    .error(function() {
		alert('error');
	    })
	    .complete(function() {
		//alert('ajax complete');
	    });
    });
});


// From https://stackoverflow.com/questions/4641346/css-to-align-label-and-input
jQuery.fn.autoWidth = function(options) 
{ 
  var settings = { 
        limitWidth   : false 
  } 

  if(options) { 
        jQuery.extend(settings, options); 
    }; 

    var maxWidth = 0; 

  this.each(function(){ 
        if ($(this).width() > maxWidth){ 
          if(settings.limitWidth && maxWidth >= settings.limitWidth) { 
            maxWidth = settings.limitWidth; 
          } else { 
            maxWidth = $(this).width(); 
          } 
        } 
  });   

  this.width(maxWidth); 
}
