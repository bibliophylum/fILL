// menu-counters.js

function update_menu_counters( lid ) {
    $.getJSON('/cgi-bin/get-menu-counts.cgi', {'lid': lid},
        function(data){
            if (data.counts.unfilled > 0) {
		var unfilled = $('#menu_borrow_unfilled a');
		if (unfilled.length > 0) {
                    unfilled[0].innerHTML = 'Unfilled: '+data.counts.unfilled;
		}
            };
            if (data.counts.overdue > 0) {
		var overdue = $('#menu_borrow_overdue a');
		if (overdue.length > 0) {
                    overdue[0].innerHTML = 'Overdue: '+data.counts.overdue;
		}
            };
            if (data.counts.renewalRequests > 0) {
		var renewal = $('#menu_lend_renewal_requests a');
		if (renewal.length > 0) {
                    renewal[0].innerHTML = 'Renewal requests: '+data.counts.renewalRequests;
		}
            };
            if (data.counts.waiting > 0) {
		var waiting = $('#menu_lend_respond a');
		if (waiting.length > 0) {
                    waiting[0].innerHTML = 'Respond: '+data.counts.waiting;
		}
            };
            //alert('get-menu-borrow-counts\nunfilled: '+data.counts.unfilled+'\noverdue: '+data.counts.overdue+'\nwaiting for response: '+data.counts.waiting+'\nrenewal requests: '+data.counts.renewalRequests);
    });
}
