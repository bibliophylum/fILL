// library_barcodes.js
function build_table( data ) {
    for (var i=0;i<data.barcodes.length;i++) {
	var ai = oTable.fnAddData( data.barcodes[i] );
	var n = oTable.fnSettings().aoData[ ai[0] ].nTr;
	var oData = oTable.fnGetData( n );
	n.setAttribute('id', n.cells[0].innerHTML+'_'+n.cells[1].innerHTML);
    }
//    oTable.fnSetColumnVis(1, false);
//    oTable.fnSetColumnVis(2, false);
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


