// library_barcodes.js
function build_table( data ) {
    for (var i=0;i<data.barcodes.length;i++) {
	var ai = oTable_barcodes.fnAddData( data.barcodes[i] );
	var n = oTable.fnSettings().aoData[ ai[0] ].nTr;
	var oData = oTable.fnGetData( n );
	// n.setAttribute('id', n.cells[0].innerHTML+'_'+n.cells[1].innerHTML);
	n.setAttribute('id', n.id+'_'+n.borrower);
    }
    toggleLayer("waitDiv");
    toggleLayer("mylistDiv");
}

function build_table_old( data ) {
    var myTable = document.createElement("table");
    myTable.setAttribute("id","gradient-style");
    var tHead = myTable.createTHead();
    var row = tHead.insertRow(-1);
    var cell;
    // Can't just use:
    // cell = row.insertCell(-1); cell.innerHTML = "ID";
    // ...because insertCell inserts TD elements, and our CSS uses TH for header cells.
    
    cell = document.createElement("TH"); cell.innerHTML = "ID"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Borrower (ID)"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Borrower"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Library name"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Barcode"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Update"; row.appendChild(cell);
    
    var tFoot = myTable.createTFoot();
    row = tFoot.insertRow(-1);
    cell = row.insertCell(-1); cell.colSpan = "6"; cell.innerHTML = "Enter these barcodes as they are in your ILS.";
    
    // explicit creation of TBODY element to make IE happy
    var tBody = document.createElement("TBODY");
    myTable.appendChild(tBody);
    
//    alert('building rows');
    for (var i=0;i<data.barcodes.length;i++) 
    {
//	alert (data.barcodes[i].id+" "+data.barcodes[i].msg_from+" "+data.barcodes[i].call_number+" "+data.barcodes[i].author+" "+data.barcodes[i].title+" "+data.barcodes[i].ts); //further debug
        row = tBody.insertRow(-1); row.id = 'req'+data.barcodes[i].borrower;
        cell = row.insertCell(-1); cell.innerHTML = data.barcodes[i].id;
        cell = row.insertCell(-1); cell.innerHTML = data.barcodes[i].borrower;
        cell = row.insertCell(-1); cell.innerHTML = data.barcodes[i].name;
        cell = row.insertCell(-1); cell.innerHTML = data.barcodes[i].library;
        cell = row.insertCell(-1); cell.innerHTML = data.barcodes[i].barcode;
        cell = row.insertCell(-1); 

	var divUpdate = document.createElement("div");
	divUpdate.id = 'divResponses'+data.barcodes[i].borrower;

	var b1 = document.createElement("input");
	b1.type = "button";
	b1.value = "Update";
	var barcodeId = data.barcodes[i].borrower;
	b1.onclick = make_barcodes_handler( barcodeId );
	divUpdate.appendChild(b1);
	
	cell.appendChild( divUpdate );
    }
    
    document.getElementById('mylistDiv').appendChild(myTable);
    
    toggleLayer("waitDiv");
    toggleLayer("mylistDiv");
}

// Explanation of why we need a function to create the buttons' onclick handlers:
// http://www.webdeveloper.com/forum/archive/index.php/t-100584.html
// Short answer: scoping and closures

function make_barcodes_handler( barcodeId ) {
    return function() { update_barcode( barcodeId ) };
}

function update_barcode( barcodeId ) {
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
	if ($row.find(':nth-child(2)').text() == barcodeId) {
	    return {
		lid: $("#lid").text(),
		bcid: $row.find(':nth-child(2)').text(),
		barcode: $row.find(':nth-child(6)').text(),
	    }
	} else {
	    return null;
	};
    }).get();

    $.getJSON('/cgi-bin/update-library-barcode.cgi', parms[0],
	      function(data){
//		  alert('change request status: '+data+'\n'+parms[0].status);
	      })
	.success(function() {
	    //alert('success');
	})
	.error(function() {
	    alert('error');
	})
	.complete(function() {
	    // slideUp doesn't work for <tr>
	    //$("#req"+barcodeId).fadeOut(400, function() { $(this).remove(); }); // toast the row
	});
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


