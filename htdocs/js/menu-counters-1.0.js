// menu-counters.js
/*
    fILL - Free/Open-Source Interlibrary Loan management system
    Copyright (C) 2012  Government of Manitoba

    menu-counters.js is a part of fILL.

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

function update_menu_counters( lid ) {
    $.getJSON('/cgi-bin/get-menu-counts.cgi', {'lid': lid},
        function(data){
            if (data.counts.unfilled > 0) {
		var unfilled = $('#menu_borrow_unfilled a');
		if (unfilled.length > 0) {
                    unfilled[0].innerHTML = 'Unfilled: '+data.counts.unfilled;
		}
            };
            if (data.counts.holds > 0) {
		var holds = $('#menu_borrow_holds a');
		if (holds.length > 0) {
                    holds[0].innerHTML = 'Holds placed: '+data.counts.holds;
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
            if (data.counts.shipping > 0) {
		var shipping = $('#menu_lend_shipping a');
		if (shipping.length > 0) {
                    shipping[0].innerHTML = 'Shipping: '+data.counts.shipping;
		}
            };
            if ((data.counts.on_hold > 0) || (data.counts.on_hold_cancel > 0)) {
		if (data.counts.on_hold_cancel > 0) {
		    var on_hold = $('#menu_lend_holds a');
		    if (on_hold.length > 0) {
			on_hold[0].innerHTML = 'On hold: '+data.counts.on_hold+'/<strong>'+data.counts.on_hold_cancel+'</strong>';
		    }
		} else {
		    var on_hold = $('#menu_lend_holds a');
		    if (on_hold.length > 0) {
			on_hold[0].innerHTML = 'On hold: '+data.counts.on_hold;
		    }
		}
            };
            if (data.counts.patron_requests > 0) {
		var patron_requests = $('#menu_borrow_new_patron_requests a');
		if (patron_requests.length > 0) {
                    patron_requests[0].innerHTML = 'New patron requests: '<div style="
  font-size: .8em;
  font-family: sans-serif;
  padding: .2em;
  margin: .2em;
  -moz-border-radius: 0px;
    -webkit-border-radius: .5em;
  border-radius: .5em;
  width: .7em;
  height: .7em;
  color: #fff;
  background-color: #ff0000;
  box-shadow: 1px 1px 2px #b3b3b3;">
  +data.counts.patron_requests;</div>
		}
            };
            //alert('get-menu-borrow-counts\nunfilled: '+data.counts.unfilled+'\nholds: '+data.counts.holds+'\noverdue: '+data.counts.overdue+'\nwaiting for response: '+data.counts.waiting+'\nrenewal requests: '+data.counts.renewalRequests);
    });
}
