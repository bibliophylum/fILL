// respond.js
function build_table( data ) {
//    alert( 'in build_table' );
    var myTable = document.createElement("table");
    myTable.setAttribute("id","gradient-style");
    var tHead = myTable.createTHead();
    var row = tHead.insertRow(-1);
    var cell;
    // Can't just use:
    // cell = row.insertCell(-1); cell.innerHTML = "ID";
    // ...because insertCell inserts TD elements, and our CSS uses TH for header cells.
    
    cell = document.createElement("TH"); cell.innerHTML = "ID"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "From"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Call #"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Author"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Title"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Timestamp"; row.appendChild(cell);
    
    var tFoot = myTable.createTFoot();
    row = tFoot.insertRow(-1);
    cell = row.insertCell(-1); cell.colSpan = "6"; cell.innerHTML = "As requests are handled, they are removed from this list.  You can see the status of all of your active ILLs in the \"Current ILLs\" screen.";
    
    // explicit creation of TBODY element to make IE happy
    var tBody = document.createElement("TBODY");
    myTable.appendChild(tBody);
    
//    alert('building rows');
    for (var i=0;i<data.unhandledRequests.length;i++) 
    {
//	alert (data.unhandledRequests[i].id+" "+data.unhandledRequests[i].msg_from+" "+data.unhandledRequests[i].call_number+" "+data.unhandledRequests[i].author+" "+data.unhandledRequests[i].title+" "+data.unhandledRequests[i].ts); //further debug
        row = tBody.insertRow(-1); row.id = 'req'+data.unhandledRequests[i].id;
        cell = row.insertCell(-1); cell.innerHTML = data.unhandledRequests[i].id;
        cell = row.insertCell(-1); cell.innerHTML = data.unhandledRequests[i].msg_from;
        cell = row.insertCell(-1); cell.innerHTML = data.unhandledRequests[i].call_number;
        cell = row.insertCell(-1); cell.innerHTML = data.unhandledRequests[i].author;
        cell = row.insertCell(-1); cell.innerHTML = data.unhandledRequests[i].title;
        cell = row.insertCell(-1); cell.innerHTML = data.unhandledRequests[i].ts;
	
    }
    
    document.getElementById('mylistDiv').appendChild(myTable);
    
    toggleLayer("waitDiv");
    toggleLayer("mylistDiv");
}

// Explanation of why we need a function to create the buttons' onclick handlers:
// http://www.webdeveloper.com/forum/archive/index.php/t-100584.html
// Short answer: scoping and closures

function make_shipit_handler( requestId ) {
    return function() { shipit( requestId ) };
}

function shipit( requestId ) {
    // NOTE: this code will find table rows based on cell contents...
    // ...as we now have <tr id='xxx'>, there's an easier way....

    // Returns [{reqid: 12, msg_to: '101'}, 
    //          {reqid: 15, msg_to: '98'},
    // Note that nth-child uses 1-based indexing, not 0-based
    var parms = $('#gradient-style tbody tr').map(function() {
	// $(this) is used more than once; cache it for performance.
	var $row = $(this);
	
	// For each row that's "mapped", return an object that
	//  describes the first and second <td> in the row.
	if ($row.find(':nth-child(1)').text() == requestId) {
	    return {
		reqid: $row.find(':nth-child(1)').text(),
		msg_to: $row.find(':nth-child(2)').text(),  // sending TO whoever original was FROM
		lid: '101', // where do we pull this from?
		status: "ILL-Answer|Shipped",
		message: "due:"+$row.find(':nth-child(7)').text()  // due-date
	    }
	} else {
	    return null;
	};
    }).get();

    $.getJSON('/cgi-bin/change-request-status.cgi', parms[0],
	      function(data){
		  //alert('change request status: '+data);
	      }
	     );
    // slideUp doesn't work for <tr>
    $("#req"+requestId).fadeOut(400, function() { $(this).remove(); }); // toast the row
}

function set_default_due_date(oForm) {
//    var defaultDueDate = oForm.elements["year"].value + '-' + oForm.elements["month"].value + '-' + oForm.elements["day"].value;
    var defaultDueDate = oForm.elements["datepicker"].value;
    var theTable = document.getElementById('gradient-style');

    var alreadyExists = false;
    var dueDateCellIndex = 0;
    for( var i = 0; i < theTable.tHead.rows[0].cells.length; i++ ) {
	if (theTable.tHead.rows[0].cells[i].innerHTML === 'Due date') {
	    alreadyExists = true;
	    dueDateCellIndex = i;
	    break;
	}
    }

    if (alreadyExists) {
	for( var r = 0; r < theTable.tBodies[0].rows.length; r++ ) {
	    theTable.tBodies[0].rows[r].cells[dueDateCellIndex].innerHTML = defaultDueDate;
	}
    } else {
	for( var x = 0; x < theTable.tHead.rows.length; x++ ) {
	    var y = document.createElement('th');
	    y.appendChild(document.createTextNode('Due date'));
	    theTable.tHead.rows[x].appendChild(y);
	    
	    y = document.createElement('th');
	    y.appendChild(document.createTextNode('Response'));
	    theTable.tHead.rows[x].appendChild(y);
	    
	}
	
	for( var z = 0; z < theTable.tBodies.length; z++ ) {
	    for( var x = 0; x < theTable.tBodies[z].rows.length; x++ ) {
		var y = document.createElement('td');
		y.appendChild(document.createTextNode( defaultDueDate ));
		theTable.tBodies[z].rows[x].appendChild(y);
		
		y = document.createElement('td');
		var b1 = document.createElement("input");
		b1.type = "button";
		b1.value = "Sent";
		var requestId = theTable.tBodies[z].rows[x].cells[0].firstChild.data;
		b1.onclick = make_shipit_handler( requestId );
		y.appendChild(b1);
		
		var b2 = document.createElement("input");
		b2.type = "button";
		b2.value = "Change due date";
		b2.onclick = function () { alert('click!'); };
		y.appendChild(b2);
		
		var b3 = document.createElement("input");
		b3.type = "button";
		b3.value = "Unfilled";
		b3.onclick = function () { alert('click!'); };
		y.appendChild(b3);
		
		theTable.tBodies[z].rows[x].appendChild(y);
		
	    }
	}
	for( var x = 0; x < theTable.tFoot.rows.length; x++ ) {
	    theTable.tFoot.rows[x].cells[0].colSpan++;
	    theTable.tFoot.rows[x].cells[0].colSpan++; // and one for the response field
	}
    } // end if(alreadyExists)
    $("#gradient-style > tbody > tr > td:nth-child(7)").stop(true,true).effect("highlight", {}, 2000);
}

function toggleLayer( whichLayer )
{
    var elem, vis;
    if( document.getElementById ) // this is the way the standards work
	elem = document.getElementById( whichLayer );
    else if( document.all ) // this is the way old msie versions work
	elem = document.all[whichLayer];
    else if( document.layers ) // this is the way nn4 works
	elem = document.layers[whichLayer];

    vis = elem.style;
    // if the style.display value is blank we try to figure it out here
    if(vis.display==''&&elem.offsetWidth!=undefined&&elem.offsetHeight!=undefined)
	vis.display = (elem.offsetWidth!=0&&elem.offsetHeight!=0)?'block':'none';
    vis.display = (vis.display==''||vis.display=='block')?'none':'block';
    //    alert('toggled ' + whichLayer);
}

function set_primary_tab(tab_id) {
    document.getElementById(tab_id).className='current_tab';
}

function set_secondary_tab(tab_id) {
    document.getElementById(tab_id).className='current_tab';
}


