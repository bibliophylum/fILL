/* A very simple client that shows a basic usage of the pz2.js
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

// DC: See https://github.com/subugoe/pazpar2-js-client ... this isn't working (yet, below)
//termLists = {"xtargets":{"maxFetch":"50","minDisplay":"1"},"medium":{"maxFetch":"12","minDisplay":"1"},"language":{"maxFetch":"5","minDisplay":"1"},"filterDate":{"maxFetch":"10","minDisplay":"5"}};

// some state vars
var curPage = 1;
var recPerPage = 20;
var totalRec = 0;
var curDetRecId = '';
var curDetRecData = null;
var curSort = 'relevance';
var curFilter = null;
var submitted = false;
var isSearching = 0;
var completionStatus = {};

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
                     ' of ' + data.merged + ' (found: ' 
                     + data.total + ')</div>';
    drawPager(pager);
    // navi
    var results = document.getElementById("results");
  
    var html = [];
    for (var i = 0; i < data.hits.length; i++) {
        var hit = data.hits[i];
	if (isSearching) {
	    html.push('<div class="record" id="recdiv_'+hit.recid+'" >'
		      +'<span>'+ (i + 1 + recPerPage * (curPage - 1)) +'. </span>'
		      +'<a href="#" class="disabled-while-searching" id="rec_'+hit.recid
		      +'"><b>' 
		      + hit["md-title"] +' </b></a>');
	} else {
	    html.push('<div class="record" id="recdiv_'+hit.recid+'" >'
		      +'<span>'+ (i + 1 + recPerPage * (curPage - 1)) +'. </span>'
		      +'<a href="#" id="rec_'+hit.recid
		      +'" onclick="showDetails(this.id);return false;"><b>' 
		      + hit["md-title"] +' </b></a>');
	}
	if (hit["md-title-remainder"] !== undefined) {
	    html.push('<span>' + hit["md-title-remainder"] + ' </span>');
	}
	if (hit["md-title-responsibility"] !== undefined) {
    	    html.push('<span>'+hit["md-title-responsibility"]+'</span>');
      	}

	if (hit["md-medium"] != undefined) {
	    html.push(' <span><font style="background-color: white; font-weight: bold">' + hit["md-medium"] + '</font></span>');
	}
	if (hit["md-largeprint"] != undefined) {
	    html.push(' <span><font style="background-color: white; font-color: midnight-blue; font-weight: bold">' + hit["md-largeprint"] + '</font></span>');
	}

        if (hit.recid == curDetRecId) {
            html.push(renderDetails(curDetRecData));
        }
      	html.push('</div>');
    }
    replaceHtml(results, html.join(''));
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
	completionStatus = {clients: data.clients, active: data.activeclients };
	if(data.activeclients != 0){
	    stat.innerHTML = '<div style="text-align:left;">Responses from<br />'+(data.clients - data.activeclients)+' of '+data.clients+' libraries.</div>';
	    stat.innerHTML += '<div id="progress_empty" style="">'; //Further styles for progress_empty in css
	    stat.innerHTML += '<div id="progress_filler" style="width:'+(((data.clients - data.activeclients) / data.clients)*130)+'px;"/>';//Further styles for progress filler in css
	    //stat.innerHTML += '<div id="stopper" style=""><input id="stopIt" type="button" value="Stop!" onClick="javascript:stopTheSearch(); return false;" class="library-style" />'
	    stat.innerHTML += '</div></div><br />';
	}else{
	    stat.innerHTML = '';
	    //debug("Search Complete");
	    isSearching = 0;
	    $(".disabled-while-searching").removeClass("disabled-while-searching");
	    $("#result-instructions").text("Click on a title for more information.");
	    $("#result-instructions").stop(true,true).effect("highlight", {}, 2000);

	    $("#countdown").TimeCircles().stop();
	    $("#status-header").text("Search complete.");
	    $("#libraries-finished").empty();
	    $("#libraries-finished").append("<p>All zServers responded to your search within "+Math.min(20,Math.round( 60 - $("#countdown").TimeCircles().getTime() ))+" seconds.</p>");
	    $("#status-note").hide();
            $("#libraries-finished").show();
            $("#countdown-div").hide();
            $("#count-or-percent-div").hide();
            $("#percent-div").hide();

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
	    } else {
		my_paz.show(0, recPerPage, curSort);
	    }
	}
    }
}


function my_onterm(data) {
    var termlists = [];
    termlists.push('<br><hr/><b>Refine search:</b>');
    termlists.push('<hr/><div class="termtitle">Subjects</div>');
    for (var i = 0; i < data.subject.length; i++ ) {
        termlists.push('<a href="#" onclick="limitQuery(\'su\', this.firstChild.nodeValue);return false;">' + data.subject[i].name + '</a><span>  (' 
              + data.subject[i].freq + ')</span><br/>');
    }
     
    termlists.push('<hr/><div class="termtitle">Authors</div>');
    for (var i = 0; i < data.author.length; i++ ) {
        termlists.push('<a href="#" onclick="limitQuery(\'au\', this.firstChild.nodeValue);return false;">' 
                            + data.author[i].name 
                            + ' </a><span> (' 
                            + data.author[i].freq 
                            + ')</span><br/>');
    }

    termlists.push('<hr/><div class="termtitle">Top Sources</div>');
    for (var i = 0; i < data.xtargets.length; i++ ) {
        termlists.push('<a href="#" target_id='+data.xtargets[i].id
            + ' onclick="limitTarget(this.getAttribute(\'target_id\'), this.firstChild.nodeValue);return false;">' + data.xtargets[i].name 
        + ' </a><span> (' + data.xtargets[i].freq + ')</span><br/>');
    }
     
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
    var html = renderDetails(curDetRecData);
    recordDiv.innerHTML += html;
}

function my_onbytarget(data) {
    var targetDiv = document.getElementById("bytarget");
    var table ='<table><thead><tr><td>Name</td><td>Target ID</td><td>Hits</td><td>Diags</td>'
        +'<td>Records</td><td>State</td></tr></thead><tbody>';
    
    for (var i = 0; i < data.length; i++ ) {
        table += "<tr>" +
	    "<td>" + '<a href="#" target_id='+data[i].id+' onclick="limitTarget(this.getAttribute(\'target_id\'), this.firstChild.nodeValue); return false;">' + data[i].name + '</a>' + "</td>" +
	    "<td>" + data[i].id + "</td>" +
            "<td>" + data[i].hits + "</td>" +
            "<td>" + data[i].diagnostic + "</td>" +
            "<td>" + data[i].records + "</td>" +
            "<td>" + data[i].state + "</td>" +
	    "</tr>";
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
    document.search.query.value = '';
    document.select.sort.onchange = onSelectDdChange;
    document.select.perpage.onchange = onSelectDdChange;
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
}

function triggerSearch ()
{
    $("#results").empty();  // clear the previous search (if any)
    isSearching = 1;
    $("#search-status").show();
    $("#countdown-finished").hide();
    $("#libraries-finished").hide();
    $("#countdown-div").show();
    $("#count-or-percent-div").show();
    $("#percent-div").show();
    $("#status-header").text("Searching all libraries");
    $("#status-note").text("Your search will finish when either the timer runs out, or all libraries have responded.");
    $("#status-note").show();

    var query = '';
    if (document.search.query.value) {
	query += document.search.query.value;
    }
    if (document.search.adv_title.value) {
	if (query != '') { query += ' and ' };
	query += 'ti="' + document.search.adv_title.value + '"';
	document.search.adv_title.value=null;
    }
    if (document.search.adv_author.value) {
	if (query != '') { query += ' and ' };
	query += 'au="' + document.search.adv_author.value + '"';
	document.search.adv_author.value=null;
    }
    if (document.search.adv_subject.value) {
	if (query != '') { query += ' and ' };
	query += 'su="' + document.search.adv_subject.value + '"';
	document.search.adv_subject.value=null;
    }
    if (document.search.adv_series.value) {
	if (query != '') { query += ' and ' };
	query += 'series="' + document.search.adv_series.value + '"';
	document.search.adv_series.value=null;
    }

    query = query.replace(/\,/g,"");  // causes 'malformed query' on some zServers

    if ($('#advanced_search').is(':visible')) { toggleAdvanced(); }
    document.search.query.value = query;  // update query so user can see it
    $("#countdown").TimeCircles().restart();
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
    switchView("recordview");  // in case limitTarget call comes from targetview
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
        var prev = '<a href="#main" id="prev" onclick="pagerPrev();">'
        +'&#60;&#60; Prev</a><b> | </b>';

    var middle = '';
    for(var i = firstClkbl; i <= lastClkbl; i++) {
        var numLabel = i;
        if(i == curPage)
            numLabel = '<b>' + i + '</b>';

        middle += '<a href="#main" onclick="showPage(' + i + ')"> '
            + numLabel + ' </a>';
    }
    
    var next = '<b> | </b><span id="next">Next &#62;&#62;</span>';
    if (pages - curPage > 0)
    var next = '<b> | </b><a href="#main" id="next" onclick="pagerNext()">'
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

function stopTheSearch(reason) {
    var retval = { finished: (completionStatus.clients - completionStatus.active),
		   waiting: (completionStatus.active - 0)
		 };
    my_paz.stop();
    if (reason == null) {
	reason = "Search stopped."
    }
    var stat = document.getElementById('stat');
    stat.innerHTML = '<div style="text-align:left;">'+reason+'</div>';
    isSearching = 0;
    my_paz.show(0, recPerPage, curSort); // make the title links active
    return retval;
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

function renderDetails(data, marker)
{
    var isElectronicResource = false;
    var details_and_form = '<div class="details" id="det_'+data.recid+'">'; 
    var details = '<table>';
    var requestForm = '<form action="/cgi-bin/lightning.cgi" method="post" target="_blank"><input type="hidden" name="rm" value="request">';
    var title;
    if (marker) details += '<tr><td>'+ marker + '</td></tr>';
    if (data["md-title"] != undefined) {
//        if(typeof data["md-title"] != "string")
//            throw new Error('not a string:'+typeof data["md-title"]);
        title = data["md-title"].toString();
	title = title.replace(/["']/g, "");
        details += '<tr><td><b>Title</b></td><td><b>:</b> '+title;
  	if (data["md-title-remainder"] !== undefined) {
	    details += ' : <span>' + data["md-title-remainder"] + ' </span>';
	    requestForm += '<input type="hidden" name="title" value="' + title + ': ' + data["md-title-remainder"] + '">';
  	} else {
	    requestForm += '<input type="hidden" name="title" value="' + title + '">';
	}
  	if (data["md-title-responsibility"] !== undefined) {
	    details += ' <span>'+ data["md-title-responsibility"] +'</span>';
  	}
 	details += '</td></tr>';
    }
    if (data["md-author"] != undefined) {
        details += '<tr><td><b>Author</b></td><td><b>:</b> ' + data["md-author"] + '</td></tr>';
	requestForm += '<input type="hidden" name="author" value="' + data["md-author"] + '">';
    }
    if (data["md-date"] != undefined) {
        details += '<tr><td><b>Publication date</b></td><td><b>:</b> ' + data["md-date"] + '</td></tr>';
	requestForm += '<input type="hidden" name="pubdate" value="' + data["md-date"] + '">';
    }
    if (data["location"][0]["md-isbn"] != undefined) {
        details += '<tr><td><b>ISBN</b></td><td><b>:</b> ' + data["location"][0]["md-isbn"] + '</td></tr>';
	requestForm += '<input type="hidden" name="isbn" value="' + data["location"][0]["md-isbn"] + '">';
    }
    if (data["md-electronic-url"] != undefined)
        details += '<tr><td><b>URL</b></td><td><b>:</b> <a href="' + data["md-electronic-url"] + '" target="_blank">' + data["md-electronic-url"] + '</a>' + '</td></tr>';

    var len=data["location"].length;
    details += '<tr><td><b>locations</b></td><td><b>:</b> ' + len + '</td></tr>';
    for (var i=0; i<len; i++) {

	// skipping Spruce locations which are closed
	if ("Spruce Libraries Cooperative" === data["location"][i]["@name"]) {
	    if (data["location"][i]["md-locallocation"] != undefined) {
		var bail=0;
		for (var lloc = 0; lloc < data["location"][i]["md-locallocation"].length; lloc++) {
		    for (var x = 0; x < window.SpruceClosed.closed.length; x++) {
			//alert(window.SpruceClosed.closed[x].symbol + ' is closed.');
			if (window.SpruceClosed.closed[x].z3950_location === data["location"][i]["md-locallocation"][lloc]) {
			    bail=1;
			}
		    }
		}
		if (bail) continue; // skip the details section below, just go on to the next pass through the loop
	    }
	}

	details += '<tr><td>&nbsp;</td><td><hr/></td><td>&nbsp;</td></tr>';
	if (data["location"][i]["md-medium"] != undefined) {
	    details += '<tr><td><b>Format</b></td><td><b>:</b> <b><font style="background-color: yellow;">' + data["location"][i]["md-medium"] + '</font></b></td></tr>';
	    if (data["location"][i]["md-medium"] == "electronicresource")
		isElectronicResource = true;
	}
	if (data["location"][i]["md-series-title"] != undefined)
	    details += '<tr><td><b>Series</b></td><td><b>:</b> ' + data["location"][i]["md-series-title"] + '</td></tr>';
	if (data["location"][i]["md-subject"] != undefined)
            details += '<tr><td><b>Subject</b></td><td><b>:</b> ' + data["location"][i]["md-subject"] + '</td></tr>';
	if (data["location"][i]["@name"] != undefined)
            details += '<tr><td><b>Location</b></td><td><b>:</b> ' + data["location"][i]["@name"] + " (" +data["location"][i]["@id"] + ")" + '</td></tr>';

	if (data["location"][i]["md-locallocation"] != undefined) {
	    for (var lloc = 0; lloc < data["location"][i]["md-locallocation"].length; lloc++) {
		details += '<tr><td><b>...at</b></td><td><b>:</b> ' + data["location"][i]["md-locallocation"][lloc];
		if (data["location"][i]["md-localcallno"] != undefined) {
		    details += ' (' + data["location"][i]["md-localcallno"][lloc] + ')';
		} else if (data["location"][i]["md-callnumber"] != undefined) {
		    details += ' (' + data["location"][i]["md-callnumber"][lloc] + ')';
		} else if (data["location"][i]["md-holding"] != undefined) {
		    details += ' (' + data["location"][i]["md-holding"] + ')';
		}
		details += '</td></tr>';
	    }
	} else if (data["location"][i]["md-holding"] != undefined) {
	    details += '<tr><td><b>Holding</b></td><td><b>:</b> ' + data["location"][i]["md-holding"]  + '</td></tr>';
	} else {
	    details += '<tr><td><b>Holding</b></td><td><b>:</b> No holdings information </td></tr>';
	}
	
//	if (data["location"][i]["md-symbol"] != undefined) {
//	    details += '<tr><td><b>Library symbol</b></td><td><b>:</b> ' + data["location"][i]["md-symbol"]  + '</td></tr>';
//	    if (data["location"][i]["md-symbol"] == 'SPRUCE') {
//		if (data["location"][i]["md-locallocation"] != undefined)
//		    details += '<tr><td><b>Spruce locations</b></td><td><b>:</b> ' + data["location"][i]["md-locallocation"]  + '</td></tr>';
//		if (data["location"][i]["md-localcallno"] != undefined)
//		    details += '<tr><td><b>Spruce callno</b></td><td><b>:</b> ' + data["location"][i]["md-localcallno"]  + '</td></tr>';
//	    }
//	}

	requestForm += '<input type="hidden" name="symbol_' + i + '" value="' + data["location"][i]["md-symbol"] + '">';
	requestForm += '<input type="hidden" name="location_' + i + '" value="' + data["location"][i]["@name"] + '">';
	requestForm += '<input type="hidden" name="holding_' + i + '" value="' + data["location"][i]["md-holding"] + '">';
	requestForm += '<input type="hidden" name="callnumber_' + i + '" value="' + data["location"][i]["md-callnumber"] + '">';
	requestForm += '<input type="hidden" name="locallocation_' + i + '" value="' + data["location"][i]["md-locallocation"] + '">';
	requestForm += '<input type="hidden" name="localcallno_' + i + '" value="' + data["location"][i]["md-localcallno"] + '">';
	requestForm += '<input type="hidden" name="medium_' + i + '" value="' + data["location"][i]["md-medium"] + '">';
    }

    if (isElectronicResource) {
	requestForm += '<p><strong>This electronic resource is not requestable through ILL.</strong></p>';
    } else {
	requestForm += '<input type="submit" class="library-style" value="Click To Request">';
    }
    requestForm += '</form>';
    details += '</table>';
    details_and_form += requestForm + details + '</div>';
    return details_and_form;
}
 //EOF
