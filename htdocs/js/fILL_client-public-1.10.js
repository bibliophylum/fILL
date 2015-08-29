/* A very simple client that shows a basic usage of the pz2.js
**
** fILL public client
*/

// create a parameters array and pass it to the pz2's constructor
// then register the form submit event with the pz2.search function
// autoInit is set to true on default
var usesessions = true;
var pazpar2path = '/pazpar2/search.pz2';
var showResponseType = '';
if (document.location.hash == '#useproxy') {
    usesessions = false;
    pazpar2path = '/service-proxy/';
    showResponseType = 'json';
}

my_paz = new pz2( { "onshow": my_onshow,
                    "showtime": 500,            //each timer (show, stat, term, bytarget) can be specified this way
                    "pazpar2path": pazpar2path,
                    "oninit": my_oninit,
                    "onstat": my_onstat,
                    "onterm": my_onterm,
                    "termlist": "xtargets,subject,author",
                    "onbytarget": my_onbytarget,
	 	    "usesessions" : usesessions,
                    "showResponseType": showResponseType,
                    "onrecord": my_onrecord } );
// some state vars
var curPage = 1;
var recPerPage = 20;
var totalRec = 0;
var curDetRecId = '';
var curDetRecData = null;
var curSort = 'relevance';
var curFilter = null;
var submitted = false;
var SourceMax = 16;
var SubjectMax = 10;
var AuthorMax = 10;
var useELMcover = 0;  // Manitoba-specific
var isSearching = 0;

//
// pz2.js event handlers:
//
function my_oninit() {
    my_paz.stat();
    my_paz.bytarget();
}

function my_onshow(data) {
    totalRec = data.merged;
    // move it out
    var pager = document.getElementById("pager");
    pager.innerHTML = "";
    pager.innerHTML +='<hr/><div style="float: right">Displaying: ' 
                    + (data.start + 1) + ' to ' + (data.start + data.num) +
                     ' of ' + data.merged + '</div>';
    drawPager(pager);

    var $newResults = $('<div/>', { 'id': "results" });
  
    for (var i = 0; i < data.hits.length; i++) {
        var hit = data.hits[i];

	var $recDiv = $('<div/>', { 'class': "record", 'id': "recdiv_"+hit.recid });
	$recDiv.append( $('<hr>') );
	$recDiv.append( $('<span>'+ (i + 1 + recPerPage * (curPage - 1)) +'. </span>') );
	if (isSearching) {
	    $recDiv.append( $('<a class="disabled-while-searching" href="#" id="rec_'+hit.recid+'" onclick="showDetails(this.id);return false;"><b>'+hit["md-title"] +' </b></a><br/>') ); 
	} else {
	    $recDiv.append( $('<a href="#" id="rec_'+hit.recid+'" onclick="showDetails(this.id);return false;"><b>'+hit["md-title"] +' </b></a><br/>') ); 
	}

	if (hit["md-title-remainder"] !== undefined) {
	    $recDiv.append( $('<span class="indent">' + hit["md-title-remainder"] + ' </span>') );
	}
	if (hit["md-title-responsibility"] !== undefined) {
	    $recDiv.append( $('<span class="indent">'+hit["md-title-responsibility"]+' </span>') );
      	}

	if (hit["md-medium"] != undefined) {
	    $recDiv.append( $('<span><font style="background-color: white; font-weight: bold">' + hit["md-medium"] + '</font></span>') );
	}

        if (hit.recid == curDetRecId) {
	    $recDiv.append( renderDetails(curDetRecData) );
	    // handle the form submission:
	    $("#request_form").submit(function( event ) {
		if ($.cookie("fILL-authentication") === "fILL") {
		    $("#request_form").append('<input type="hidden" name="username" value="' + $("#username").text() + '">'); 
		} else {
		    // externally authenticated, so username is barcode
		    $("#request_form").append('<input type="hidden" name="username" value="' + $("#barcode").text() + '">'); 
		}
		$("#request_form").append('<input type="hidden" name="oid" value=' + $("#oid").text() + '">');
		request();
		event.preventDefault();
	    });
	    // can't be done in coverImage - have to wait until container appended to div
	    if (useELMcover) {
		$("#cover").attr("src","/img/fill-cover-elm.png");
	    }
	}
	$newResults.append( $recDiv );
    }
    $("#results").replaceWith( $newResults );
}

//function my_onstat(data) {
//    var stat = document.getElementById("stat");
//    if (stat == null)
//	return;
//    
//    stat.innerHTML = '<b> .:STATUS INFO</b> -- Active clients: '
//                        + data.activeclients
//                        + '/' + data.clients + ' -- </span>'
//                        + '<span>Retrieved records: ' + data.records
//                        + '/' + data.hits + ' :.</span>';
//}

// From Ohio Web Library, http://www.ohioweblibrary.org/
function my_onstat(data) {
    var stat = document.getElementById('stat');
    if(stat != null){
	if(data.activeclients != 0){
	    stat.innerHTML = '<div style="text-align:left;">Searching...</div>';
	    stat.innerHTML += '<div id="progress_empty" style="">'; //Further styles for progress_empty in css
	    stat.innerHTML += '<div id="progress_filler" style="width:'+(((data.clients - data.activeclients) / data.clients)*130)+'px;"/>';//Further styles for progress filler in css
	    stat.innerHTML += '</div></div><br />';
	}else{
	    stat.innerHTML = '';
	    //debug("Search Complete");
	    $(".disabled-while-searching").removeClass("disabled-while-searching");
	    $("#result-instructions").text("Click on a title for more information.");
	    $("#result-instructions").stop(true,true).effect("highlight", {}, 2000);
	    isSearching = 0;
	    if(data.hits[0] < 1){
		var querybox = document.getElementById("query");
		if(querybox.value != ""){
		    var pager = document.getElementById("pager");
		    var pager2 = document.getElementById("pager2");
		    var results = document.getElementById("results");
		    var termlist = document.getElementById("termlist");
		    pager.innerHTML = "";
		    pager2.innerHTML = "";
		    results.innerHTML = "<br>" + querybox.value + " returned 0 results";
		    termlist.innerHTML = '';
		}
	    }
	}
    }
}


function my_onterm(data) {
    var termlists = [];
    termlists.push('<br><hr/><b>Refine search by:</b>');
    termlists.push('<hr/><div class="termtitle">Subjects</div>');
    for (var i = 0; i < data.subject.length && i < SubjectMax; i++ ) {
        termlists.push('<a href="#" onclick="limitQuery(\'su\', this.firstChild.nodeValue);return false;">' + data.subject[i].name + '</a><span>  (' 
              + data.subject[i].freq + ')</span><br/>');
    }
     
    termlists.push('<hr/><div class="termtitle">Authors</div>');
    for (var i = 0; i < data.author.length && i < AuthorMax; i++ ) {
        termlists.push('<a href="#" onclick="limitQuery(\'au\', this.firstChild.nodeValue);return false;">' 
                            + data.author[i].name 
                            + ' </a><span> (' 
                            + data.author[i].freq 
                            + ')</span><br/>');
    }
    /*
    termlists.push('<hr/><div class="termtitle">.::Sources</div>');
    for (var i = 0; i < data.xtargets.length && i < SourceMax; i++ ) {
        termlists.push('<a href="#" target_id='+data.xtargets[i].id
            + ' onclick="limitTarget(this.getAttribute(\'target_id\'), this.firstChild.nodeValue);return false;">' + data.xtargets[i].name 
        + ' </a><span> (' + data.xtargets[i].freq + ')</span><br/>');
    }
    */
    var termlist = document.getElementById("termlist");
    replaceHtml(termlist, termlists.join(''));
}

function my_onrecord(data) {
    // FIXME: record is async!!
    clearTimeout(my_paz.recordTimer);
    // in case on_show was faster to redraw element
    var detRecordDiv = document.getElementById('det_'+data.recid);
    if (detRecordDiv) return;
    curDetRecData = data;
    var recordDiv = document.getElementById('recdiv_'+curDetRecData.recid);
    var $detDiv = renderDetails(curDetRecData);
    // convert the DOM elm returned from getElementById into a jQuery object,
    // and append the detail div jQuery object returned from renderDetails.
    $(recordDiv).append( $detDiv );

    // handle the form submission:
    $("#request_form").submit(function( event ) {
	if ($.cookie("fILL-authentication") === "fILL") {
	    $("#request_form").append('<input type="hidden" name="username" value="' + $("#username").text() + '">'); 
	} else {
	    // externally authenticated, so username is barcode
	    $("#request_form").append('<input type="hidden" name="username" value="' + $("#barcode").text() + '">'); 
	}
	$("#request_form").append('<input type="hidden" name="oid" value="' + $("#oid").text() + '">');
	request();
	event.preventDefault();
    });

    // can't be done in coverImage - have to wait until container appended to div
    if (useELMcover) {
	$("#cover").attr("src","/img/fill-cover-elm.png");
    }
}

function my_onbytarget(data) {
    var targetDiv = document.getElementById("bytarget");
    var table ='<table><thead><tr><td>Target ID</td><td>Hits</td><td>Diags</td>'
        +'<td>Records</td><td>State</td></tr></thead><tbody>';
    
    for (var i = 0; i < data.length; i++ ) {
        table += "<tr><td>" + data[i].id +
            "</td><td>" + data[i].hits +
            "</td><td>" + data[i].diagnostic +
            "</td><td>" + data[i].records +
            "</td><td>" + data[i].state + "</td></tr>";
    }

    table += '</tbody></table>';
    targetDiv.innerHTML = table;
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

// wait until the DOM is ready
function domReady () 
{ 
    document.search.onsubmit = onFormSubmitEventHandler;
//    document.search.query.value = '';
    document.select.sort.onchange = onSelectDdChange;
    document.select.perpage.onchange = onSelectDdChange;
    if (document.search.query.value) {
	// if we're coming from the search box on another page,
	// d.s.q will have a value.  Click the submit button...
	$("#search-submit-button").click();
    }
}

// when search button pressed
function onFormSubmitEventHandler() 
{
    resetPage();
    loadSelect();
    $("#result-instructions").text("You will be able to click on the titles when the search is done.");
    $("#result-instructions").stop(true,true).effect("highlight", {}, 2000);
    triggerSearch();
    submitted = true;
    $("#image").hide();
    return false;
}

function onSelectDdChange()
{
    if (!submitted) return false;
    resetPage();
    loadSelect();
    my_paz.show(0, recPerPage, curSort);
    return false;
}

function resetPage()
{
    curPage = 1;
    totalRec = 0;
    var AVnotice = document.getElementById('AVnotice');
    if (AVnotice) {
	AVnotice.style.display = 'none';
    }
    var ranking = document.getElementById('ranking');
    if (ranking) {
	ranking.style.display = 'block';
    }
}

function triggerSearch ()
{
    isSearching = 1;
    my_paz.search(document.search.query.value, recPerPage, curSort, curFilter);
}

function loadSelect ()
{
    curSort = document.select.sort.value;
    recPerPage = document.select.perpage.value;
}

// limit the query after clicking the facet
function limitQuery (field, value)
{
    document.search.query.value += ' and ' + field + '="' + value + '"';
    onFormSubmitEventHandler();
}

// limit by target functions
function limitTarget (id, name)
{
    var navi = document.getElementById('navi');
    navi.innerHTML = 
        'Source: <a class="crossout" href="#" onclick="delimitTarget();return false;">'
        + name + '</a>';
    navi.innerHTML += '<hr/>';
    curFilter = 'pz:id=' + id;
    resetPage();
    loadSelect();
    triggerSearch();
    return false;
}

function delimitTarget ()
{
    var navi = document.getElementById('navi');
    navi.innerHTML = '';
    curFilter = null; 
    resetPage();
    loadSelect();
    triggerSearch();
    return false;
}

function drawPager (pagerDiv)
{
    //client indexes pages from 1 but pz2 from 0
    var onsides = 6;
    var pages = Math.ceil(totalRec / recPerPage);
    
    var firstClkbl = ( curPage - onsides > 0 ) 
        ? curPage - onsides
        : 1;

    var lastClkbl = firstClkbl + 2*onsides < pages
        ? firstClkbl + 2*onsides
        : pages;

    var prev = '<span id="prev">&#60;&#60; Prev</span><b> | </b>';
    if (curPage > 1)
        var prev = '<a href="#" id="prev" onclick="pagerPrev();">'
        +'&#60;&#60; Prev</a><b> | </b>';

    var middle = '';
    for(var i = firstClkbl; i <= lastClkbl; i++) {
        var numLabel = i;
        if(i == curPage)
            numLabel = '<b>' + i + '</b>';

        middle += '<a href="#" onclick="showPage(' + i + ')"> '
            + numLabel + ' </a>';
    }
    
    var next = '<b> | </b><span id="next">Next &#62;&#62;</span>';
    if (pages - curPage > 0)
    var next = '<b> | </b><a href="#" id="next" onclick="pagerNext()">'
        +'Next &#62;&#62;</a>';

    predots = '';
    if (firstClkbl > 1)
        predots = '...';

    postdots = '';
    if (lastClkbl < pages)
        postdots = '...';

    pagerDiv.innerHTML += '<div style="float: clear">' 
        + prev + predots + middle + postdots + next + '</div><hr/>';
}

function showPage (pageNum)
{
    curPage = pageNum;
    my_paz.showPage( curPage - 1 );
}

// simple paging functions

function pagerNext() {
    if ( totalRec - recPerPage*curPage > 0) {
        my_paz.showNext();
        curPage++;
    }
}

function pagerPrev() {
    if ( my_paz.showPrev() != false )
        curPage--;
}

// swithing view between targets and records

function switchView(view) {
    
    var targets = document.getElementById('targetview');
    var records = document.getElementById('recordview');
    
    switch(view) {
        case 'targetview':
            targets.style.display = "block";            
            records.style.display = "none";
            break;
        case 'recordview':
            targets.style.display = "none";            
            records.style.display = "block";
            break;
        default:
            alert('Unknown view.');
    }
}

// detailed record drawing
function showDetails (prefixRecId) {
    var recId = prefixRecId.replace('rec_', '');
    var oldRecId = curDetRecId;
    curDetRecId = recId;
    
    // remove current detailed view if any
    var detRecordDiv = document.getElementById('det_'+oldRecId);
    // lovin DOM!
    if (detRecordDiv)
      detRecordDiv.parentNode.removeChild(detRecordDiv);

    // if the same clicked, just hide
    if (recId == oldRecId) {
        curDetRecId = '';
        curDetRecData = null;
        return;
    }
    // request the record
    my_paz.record(recId);
}

function replaceHtml(el, html) {
  var oldEl = typeof el === "string" ? document.getElementById(el) : el;
  /*@cc_on // Pure innerHTML is slightly faster in IE
    oldEl.innerHTML = html;
    return oldEl;
    @*/
  var newEl = oldEl.cloneNode(false);
  newEl.innerHTML = html;
  oldEl.parentNode.replaceChild(newEl, oldEl);
  /* Since we just removed the old element from the DOM, return a reference
     to the new element, which can be used to restore variable references. */
  return newEl;
};

function ImgError(source){
	source.src = "/img/fill-cover.png";
	source.onerror = "";
	return true;
}

function coverImage(lccn,isbn) {
    var cover = '<td>';
    if ((isbn != undefined) || (lccn != undefined)) {
	if (lccn != undefined) {
	    cover += '<img id="cover" src="https://covers.openlibrary.org/b/LCCN/' + lccn[0] + '-M.jpg?default=false" onerror="ImgError(this)">';
	} else if (isbn != undefined) {
	    cover += '<img id="cover" src="https://covers.openlibrary.org/b/ISBN/' + isbn[0] + '-M.jpg?default=false" onerror="ImgError(this)">';
	}
    } else {
	cover += '<img id="cover" src="/img/fill-cover.png">';
    }
    cover += '</td>';
    return cover;
}

function primaryDetails(data) {
    var primary = '<table class="primary_info">';

    var title;
    if (data["md-title"] != undefined) {
        title = data["md-title"].toString();
	title = title.replace(/["']/g, "");
        primary += '<tr><td><b>Title</b></td><td><b>:</b> '+title;
  	if (data["md-title-remainder"] !== undefined) {
	    primary += ' : <span>' + data["md-title-remainder"] + ' </span>';
	}
  	if (data["md-title-responsibility"] !== undefined) {
	    primary += ' <span>'+ data["md-title-responsibility"] +'</span>';
  	}
 	primary += '</td></tr>';
    }
    if (data["md-date"] != undefined)
        primary += '<tr><td><b>Publication date</b></td><td><b>:</b> ' + data["md-date"] + '</td></tr>';
    if (data["md-author"] != undefined) {
        primary += '<tr><td><b>Author</b></td><td><b>:</b> ' + data["md-author"] + '</td></tr>';
    }
    useELMcover = 0;  // reset
    if (data["location"][0]["md-electronic-url"] != undefined) {
	var url = String(data["location"][0]["md-electronic-url"]);
	// for us, all libraries have access to the same pool of Overdrive titles
	// (using the same URL), so it makes sense to show the first one here.
	// Patrons will be asked to log in to Overdrive when they attempt to borrow.
	if (url.toLowerCase().indexOf('elm.lib.overdrive.com') >= 0) {
            primary += '<tr><td><b>eLibraries Manitoba</b></td><td><b>:</b> <a href="' + data["location"][0]["md-electronic-url"] + '" target="_blank" style="text-decoration:underline">' + 'Find this title on eLibraries Manitoba...' + '</a>' + '</td></tr>';
	    useELMcover = 1;
	}
    }

    var len=data["location"].length;
    if (len > 0) {
	if ((data["location"][0]["md-medium"] != undefined)) {
	    primary += '<tr><td><b>Format</b></td><td><b>:</b> <b><font style="background-color: yellow;">' + data["location"][0]["md-medium"] + '</font></b></td></tr>';
	}
    }
    primary += '<tr><td><b>Locations</b></td><td><b>:</b> ' + len + '</td></tr>';
    primary += '</table>';
    return primary;
}

function secondaryDetails(data) {
    var secondary = '<div id="secondary_info_div"><table class="secondary_info">';  // start new table for location info

    var len=data["location"].length;
    for (var i=0; i<len; i++) {

	// temp fix for skipping Spruce locations
//	if ("Spruce Co-operative" === data["location"][i]["@name"]) {
//	    if (data["location"][i]["md-locallocation"] != undefined) {
//		var bail=0;
//		for (var lloc = 0; lloc < data["location"][i]["md-locallocation"].length; lloc++) {
//		    if ("MSTOS" === data["location"][i]["md-locallocation"][lloc]) {
//			bail=1;
//		    }
//		}
//		if (bail) continue;
//	    }
//	}

	secondary += '<tr><td>&nbsp;</td><td><hr/></td><td>&nbsp;</td></tr>';
	if (data["location"][i]["md-medium"] != undefined) {
	    secondary += '<tr><td><b>Format</b></td><td><b>:</b> <b>' + data["location"][i]["md-medium"] + '</font></b></td></tr>';
	    if (data["location"][i]["md-medium"] == "electronicresource")
		isElectronicResource = true;
	}
	if (data["location"][i]["md-series-title"] != undefined)
	    secondary += '<tr><td><b>Series</b></td><td><b>:</b> ' + data["location"][i]["md-series-title"] + '</td></tr>';
	if (data["location"][i]["md-subject"] != undefined)
            secondary += '<tr><td><b>Subject</b></td><td><b>:</b> ' + data["location"][i]["md-subject"] + '</td></tr>';
	if (data["location"][i]["@name"] != undefined)
            secondary += '<tr><td><b>Location</b></td><td><b>:</b> ' + data["location"][i]["@name"] + " (" +data["location"][i]["@id"] + ")" + '</td></tr>';

	if (data["location"][i]["md-locallocation"] != undefined) {
	    for (var lloc = 0; lloc < data["location"][i]["md-locallocation"].length; lloc++) {
		secondary += '<tr><td><b>...at</b></td><td><b>:</b> ' + data["location"][i]["md-locallocation"][lloc];
		if (data["location"][i]["md-localcallno"] != undefined) {
		    secondary += ' (' + data["location"][i]["md-localcallno"][lloc] + ')';
		} else if (data["location"][i]["md-callnumber"] != undefined) {
		    secondary += ' (' + data["location"][i]["md-callnumber"][lloc] + ')';
		} else if (data["location"][i]["md-holding"] != undefined) {
		    secondary += ' (' + data["location"][i]["md-holding"] + ')';
		}
		secondary += '</td></tr>';
	    }
	} else if (data["location"][i]["md-holding"] != undefined) {
	    secondary += '<tr><td><b>Holding</b></td><td><b>:</b> ' + data["location"][i]["md-holding"]  + '</td></tr>';
	} else {
	    secondary += '<tr><td><b>Holding</b></td><td><b>:</b> No holdings information </td></tr>';
	}
	
    }

    secondary += '</table></div>';
    return secondary;
}

function buildRequestForm(data) {
    var requestForm = '<div id="request_form_div"><form id="request_form" action="" method="post">';
    var isElectronicResource = false;

    var title;
    if (data["md-title"] != undefined) {
        title = data["md-title"].toString();
	title = title.replace(/["']/g, "");
  	if (data["md-title-remainder"] !== undefined) {
	    requestForm += '<input type="hidden" name="title" value="' + title + ': ' + data["md-title-remainder"] + '">';
  	} else {
	    requestForm += '<input type="hidden" name="title" value="' + title + '">';
	}
    }
    if (data["md-author"] != undefined) {
	requestForm += '<input type="hidden" name="author" value="' + data["md-author"] + '">';
    }
    if (data["md-date"] != undefined) {
	requestForm += '<input type="hidden" name="pubdate" value="' + data["md-date"] + '">';
    }
    if (data["location"][0]["md-isbn"] != undefined) {
	requestForm += '<input type="hidden" name="isbn" value="' + data["location"][0]["md-isbn"] + '">';
    }

    var len=data["location"].length;
    for (var i=0; i<len; i++) {

	if (data["location"][i]["md-medium"] != undefined) {
	    if (data["location"][i]["md-medium"] == "electronicresource")
		isElectronicResource = true;
	}
	requestForm += '<input type="hidden" name="symbol_' + i + '" value="' + data["location"][i]["md-symbol"] + '">';
	requestForm += '<input type="hidden" name="location_' + i + '" value="' + data["location"][i]["@name"] + '">';
	requestForm += '<input type="hidden" name="holding_' + i + '" value="' + data["location"][i]["md-holding"] + '">';
	requestForm += '<input type="hidden" name="callnumber_' + i + '" value="' + data["location"][i]["md-callnumber"] + '">';
	requestForm += '<input type="hidden" name="locallocation_' + i + '" value="' + data["location"][i]["md-locallocation"] + '">';
	requestForm += '<input type="hidden" name="localcallno_' + i + '" value="' + data["location"][i]["md-localcallno"] + '">';
	requestForm += '<input type="hidden" name="medium_' + i + '" value="' + data["location"][i]["md-medium"] + '">';
    }

    if (isElectronicResource) {
	if (data["location"][0]["md-electronic-url"] != undefined) {
	    var url = String(data["location"][0]["md-electronic-url"]);
	    // for us, all libraries have access to the same pool of Overdrive titles
	    // (using the same URL), so it makes sense to show the first one here.
	    // Patrons will be asked to log in to Overdrive when they attempt to borrow.
	    if (url.toLowerCase().indexOf('elm.lib.overdrive.com') >= 0) {
		requestForm += '<p><strong>Your library may provide access to this electronic resource through eLibraries Manitoba.</strong></p>';
		requestForm += '<p><a href="' + data["location"][0]["md-electronic-url"] + '" target="_blank" style="text-decoration:underline">' + 'Find this title on eLibraries Manitoba...' + '</a>' + '</p>';

	    } else {
		requestForm += '<p><strong>This is an electronic resource.  Please contact your library to see if it is available to you.</strong></p>';
	    }
	} else {
	    requestForm += '<p><strong>This is an electronic resource.  Please contact your library to see if it is available to you.</strong></p>';
	}
    } else {
	requestForm += '<input type="submit" class="public-style" value="Click to request">';
    }
    requestForm += '</form></div>';

    return requestForm;
}

function renderDetails(data, marker) 
{
    var $detDiv = $('<div>', { "class": "details",
			       "id": "det_"+data.recid
			     });
    
    var $table = $('<table></table>', { "id" : "detTable" } ).appendTo( $detDiv );
    var $tr = $('<tr></tr>').appendTo( $table );
    $tr.append( coverImage(data["md-lccn"],data["md-isbn"]) );  // image td

    var $td = $('<td></td>').appendTo( $tr );
    var $primary = $('<div>', { "id": "primary" } ).appendTo( $td );  // return correct div to 'primary' var
    $td.append( $('<div>', { "id": "confirmed", "style": "display:none" }));
    $td.append( $('<div>', { "id": "couldNotCancel", "style": "display:none" }));

    $primary.append( buildRequestForm(data) );
    $primary.append( primaryDetails(data) );

    var $showLocDet = $('<a>', { "id": "showLocDet",
				 "href": "javascript:void(0)",
				 "onclick": "toggleLocationDetails()"
			       });
    $showLocDet.append("Show location details...");
    $detDiv.append( $showLocDet );

    var $hideLocDet = $('<a>', { "id": "hideLocDet",
				 "style": "display:none",
				 "href": "javascript:void(0)",
				 "onclick": "toggleLocationDetails()"
			       });
    $hideLocDet.append("Hide location details...");
    $detDiv.append( $hideLocDet );

    $detDiv.append( secondaryDetails(data) );

//    alert( $detDiv.html() );

    return $detDiv;
}
/*
function renderDetails_old(data, marker)
{
    var details = '';

    details += '<table><tr>';
    details += coverImage(data["md-lccn"],data["md-isbn"]);

    details += '<td>';

    if (marker) details += '<tr><td>'+ marker + '</td></tr>';

    details += primaryDetails(data);
    details += '</td></tr></table>';  // end image/header table

    details += '<a id="showLocDet" href="javascript:void(0)" onclick="toggleLocationDetails();">Show location details...</a>'
    details += '<a id="hideLocDet" style="display:none" href="javascript:void(0)" onclick="toggleLocationDetails();">Hide location details...</a>'

    details += secondaryDetails(data);

    var requestForm = buildRequestForm(data);

    var details_and_form = '<div class="details" id="det_'+data.recid+'">' + requestForm + details + '</div>';
    return details_and_form;
}
*/

function toggleLocationDetails() {
//    var lTable = document.getElementById("locationDetails");
//    lTable.style.display = (lTable.style.display == "table") ? "none" : "table";

//    $('.secondary_info').css('display', 'table')

    $('#showLocDet').toggle();
    $('#hideLocDet').toggle();
    $('.secondary_info').toggle();
    return false;
}


function request() {
    var $myForm=$("#request_form");
    $.getJSON('/cgi-bin/make-patron-request.cgi', $myForm.serialize(),
	      function(data){
		  //alert('...');
	      })
	.success(function( data ) {
//	    alert('success');
	    $("#confirmed").empty();
	    $("#confirmed").append('<h2>Your request has been placed.</h2>');
	    
	    var $cancelForm = $('<form>', { "id": "cancel_form", 
					    "action": "",
					    "method": "post"
					  });
	    $cancelForm.append('<input type="hidden" name="prid" value="'+data.prid+'">');
	    $cancelForm.append('<input type="submit" class="butlink" style="height:50px; min-width:150px; font-weight:bold" value="Click to cancel this request">');
	    $("#confirmed").append( $cancelForm );

	    var $table = $('<table>').appendTo($("#confirmed"));
	    $table.append('<tr><td>Requesting user</td><td>:'+data.user+'</td></tr>');
	    $table.append('<tr><td>Title</td><td>:'+data.title+'</td></tr>');
	    $table.append('<tr><td>Author</td><td>:'+data.author+'</td></tr>');
	    $table.append('<tr><td>Format</td><td>:<font style="background-color: yellow;">'+data.medium+'</font></td></tr>');
	    $("#confirmed").append('<p>Your librarian will see if another Manitoba public library is able to lend this title to '+data.library+' at this time.</p>');


	    // handle the form submission:
	    $("#cancel_form").submit(function( event ) {
		cancel_request();
		event.preventDefault();
	    });

	    $("#primary").toggle();
	    $("#confirmed").toggle();
	})
	.error(function( data ) {
	    alert('error: could not make this request at this time');
	})
	.complete(function() {
//	    alert('complete');
	});
}


function cancel_request() {
    var $myForm=$("#cancel_form");
    $.getJSON('/cgi-bin/cancel-patron-request.cgi', $myForm.serialize(),
	      function(data){
//		  alert('...');
	      })
	.success(function( data ) {
//	    alert('success');
	    if (data.success) {
		$("#primary").toggle();
		$("#confirmed").toggle();
	    } else {
		// The librarian has already handled the request.
		$("#couldNotCancel").empty();
		$("#couldNotCancel").append('<h2>Unable to cancel</h2>');
		$("#couldNotCancel").append('<p>Your library has already processed this request.</p>');
		$("#couldNotCancel").append('<p>Contact your library to have them cancel the request.</p>');
		$("#confirmed").toggle();
		$("#couldNotCancel").toggle();
	    }
	})
	.error(function() {
	    alert('error: could not cancel this request at this time');
	})
	.complete(function() {
//	    alert('complete');
	});
}


 //EOF
