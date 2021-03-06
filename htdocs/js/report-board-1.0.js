// report-board.js
/*
    fILL - Free/Open-Source Interlibrary Loan management system
    Copyright (C) 2012  Government of Manitoba

    report-board.js is a part of fILL.

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

    $("#waitDiv").hide();
    $("#report-content").hide();
    $("#printButton").hide();
    $("#printNote").hide();

    $("#year").val( new Date().getFullYear() );
    $("#month").val( new Date().getMonth() );

    $("#printButton").on("click", function() {
	$("#report-content").printThis();
    });

    $("#dateButton").on("click", function() {
	$("#waitDiv").show();
	$("#printButton").hide();
	$("#printNote").hide();
	$("#report-content").hide();

	var parms = { 
	    oid: $("#oid").text(),
	    year: $("#year").val(),
	    month: $("#month").val()
	}
	
	$.getJSON('/cgi-bin/reports/board-report.cgi',
		  parms,
		  function(data){
		      $("#title-library").text( data.report.org_name );
		      $("#title-month").text( data.report.month_name );
		      $("#title-year").text( data.report.year );

		      $("#chart-borrowing").attr("src", "data:image/png;base64,"+data.report.charts.borrowing);
		      $("#chart-lending").attr("src", "data:image/png;base64,"+data.report.charts.lending);

		      // Borrowing
		      var b = data.report.borrowing;

		      $("#borrowing-detail-month").text( data.report.month_name );
		      $("#borrowing-requests").text( b.requests.books_requested.total );
		
		      $("#borrowing-request-types").empty();
		      $.each(b.requests.books_requested.type, function( key, value ){
			  $("#borrowing-request-types").append("<li>"+key+": "+value+"</li>");
		      });
		      $("#chart-info-month").text( data.report.month_name );
		      $("#borrowing-borrowed").text( b.we_received.total );
		      $("#borrowing-unfilled-types").empty();
		      if (b.requests_unfilled.total != null) {
			  $("#borrowing-unfilled").text( b.requests_unfilled.total );
			  $.each(b.requests_unfilled.type, function( key, value ){
			      $("#borrowing-unfilled-types").append("<li>"+key+": "+value+"</li>");
			  });
		      } else {
			  //$("#borrowing-unfilled").text( "0" );
			  $("#borrowing-unfilled-types").parent().text("We received no 'unfilled' notifications this month");
		      } 

		      if (b.change_over_previous_year != null) {
			  $("#borrowing-requests-change-base").text( b.requests.books_requested.total );
			  $("#borrowing-requests-change-month").text( data.report.month_name );
			  $("#borrowing-requests-change-month2").text( data.report.month_name );
			  $("#borrowing-change").text( b.change_over_previous_year );
			  $("#p-borrowing-change").show();
		      } else {
			  $("#p-borrowing-change").hide();
		      }

		      $("#borrowing-value-library").text( data.report.org_name );
		      $("#borrowing-value-month").text( data.report.month_name );
		      $("#borrowing-value").text( b.value );

		      // Lending
		      $("#title2-library").text( data.report.org_name );
		      $("#title2-month").text( data.report.month_name );
		      $("#title2-year").text( data.report.year );

		      var l = data.report.lending;
		      $("#lending-detail-month").text( data.report.month_name );
		      $("#lending-detail-library").text( data.report.org_name );
		      $("#lending-requests").text( l.requests_to_lend.total );
		      $("#lending-shipped").text( l.shipped.total );
		      $("#lending-unfilled").text( l.responded_unfilled.total );
		      $("#lending-unfilled-status").empty();
		      if (l.responded_unfilled.status != null) {
			  $.each(l.responded_unfilled.status, function( key, value ){
			      $("#lending-unfilled-status").append("<li>"+key+": "+value+"</li>");
			  });
		      } else {
			  $("#lending-unfilled-status").parent().text("We filled all ILL requests this month");
		      }
		      if (l.change_over_previous_year.requests != null) {
			  $("#lending-requests-change-base").text( l.requests_to_lend.total );
			  $("#lending-requests-change-month").text( data.report.month_name );
			  $("#lending-requests-change-month2").text( data.report.month_name );
			  $("#lending-requests-change").text( l.change_over_previous_year.requests );
			  $("#p-lending-requests-change").show();
		      } else {
			  $("#p-lending-requests-change").hide();
		      }

		      if (l.change_over_previous_year.requests != null) {
			  $("#lending-shipped-change-base").text( l.shipped.total );
			  $("#lending-shipped-change-month").text( data.report.month_name );
			  $("#lending-shipped-change-month2").text( data.report.month_name );
			  $("#lending-shipped-change").text( l.change_over_previous_year.shipped );
			  $("#p-lending-shipping-change").show();
		      } else {
			  $("#p-lending-shipping-change").hide();
		      }
		  })
	    .success(function() {
		//alert('success');
		$("#report-content").show();
		$("#printButton").show();
		$("#printNote").show();
	    })
	    .error(function() {
		alert('error');
	    })
	    .complete(function() {
		$("#waitDiv").hide();
	    });
    });

});

