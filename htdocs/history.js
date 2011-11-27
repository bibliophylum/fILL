// history.js
function build_table( data ) {
    for (var i=0;i<data.history.borrowing.length;i++) {
	oTable_borrowing.fnAddData( [
	    data.history.borrowing[i].id,
	    data.history.borrowing[i].title,
	    data.history.borrowing[i].author,
	    data.history.borrowing[i].patron_barcode,
	    data.history.borrowing[i].ts
	] );
    }
    for (var i=0;i<data.history.lending.length;i++) {
	oTable_lending.fnAddData( [
	    data.history.lending[i].id,
	    data.history.lending[i].title,
	    data.history.lending[i].author,
	    data.history.lending[i].requester,
	    data.history.lending[i].ts
	] );
    }
    toggleLayer("waitDiv");
    toggleLayer("mylistDiv");
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


