// welcome.js
/*
    fILL - Free/Open-Source Interlibrary Loan management system
    Copyright (C) 2012  Government of Manitoba

    welcome.js is a part of fILL.

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
    
    set_primary_tab("menu_home");
    
    $(function() {
	$("#accordion").accordion({
	    heightStyle: "content"
	});
    });
    
    $("#zserver").on("click", function(e){
	e.preventDefault();
	window.location = "/cgi-bin/myaccount.cgi?rm=myaccount_test_zserver_form";
    });

    $("#opt-in-returns-only").on("change", function(e){
        var parms = {
            "oid": $("#oid").text(),
            "opt_in_returns_only": $('#opt-in-returns-only').prop('checked'),
	    };
        $.getJSON('/cgi-bin/update-library-opt-in-returns-only.cgi', parms,
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
    
    $(function() {    
	$.getJSON('/cgi-bin/has-opted-in-returns-only.cgi', {'oid': $("#oid").text()},
		  function(data){
		      $('#opt-in-returns-only').prop('checked', data.opt_in_returns_only);
		  })
	    .done(function() {
		//alert('success!\n'+data);
	    })
	    .fail(function() {
		//alert('error testing zServer!');
	    })
	    .always(function() {
		//alert('ajax complete');
//		$("#waitDiv").hide();
	    });
    });

    $(function() {
	$.getJSON('/cgi-bin/get-menu-counts.cgi', {'oid': $("#oid").text()},
		  function(data) {
		      var glances = [
			  { "id":"glance-new-patron-requests",
			    "text":"New patron requests:",
			    "count":data.counts.patron_requests
			  },
			  { "id":"glance-waiting-for-response",
			    "text":"Waiting for response:",
			    "count":data.counts.waiting
			  },
			  { "id":"glance-pending",
			    "text":"Pending:",
			    "count":data.counts.pending
			  },
			  { "id":"glance-on-hold",
			    "text":"On hold:",
			    "count":  data.counts.on_hold
			  },
			  { "id":"glance-on-hold-cancelled",
			    "text":"On hold, but request cancelled by borrower:",
			    "count": data.counts.on_hold_cancel
			  },
			  { "id":"glance-unfilled",
			    "text":"Unfilled:",
			    "count":data.counts.unfilled
			  },
			  { "id":"glance-shipping",
			    "text":"Ready to ship:",
			    "count":data.counts.shipping
			  },
			  { "id":"glance-holds",
			    "text":"Holds placed by lender:",
			    "count":data.counts.holds
			  },
			  { "id":"glance-cannot-renew",
			    "text":"Could not be renewed:",
			    "count":data.counts.cannot_renew
			  },
			  { "id":"glance-renewalRequests",
			    "text":"Renewal requests:",
			    "count":data.counts.renewalRequests
			  },
			  { "id":"glance-overdue",
			    "text":"Overdue:",
			    "count":data.counts.overdue
			  },
			  { "id":"glance-lost",
			    "text":"Lost:",
			    "count":data.counts.lost
			  }
		      ];
		      for (var i = 0, len = glances.length; i < len; i++) {
			  var anchor = $('#'+glances[i].id);
			  if (glances[i].count > 0) {
			      anchor.text(glances[i].text+' ');
			      var s = $('<span class="circle"></span>');
			      s.text(glances[i].count);
			      anchor.append(s);
			  } else {
			      anchor.text(glances[i].text+' 0');
			  }
		      }		      
		  });
    });
	     
    $(function() {    
	$.getJSON('/cgi-bin/check-zserver-connectivity.cgi', {libsym: $("#libsym").text()},
		  function(data){
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
});
    
