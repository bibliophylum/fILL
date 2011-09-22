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
	      html.push('<div class="record" id="recdiv_'+hit.recid+'" >'
            +'<span>'+ (i + 1 + recPerPage * (curPage - 1)) +'. </span>'
            +'<a href="#" id="rec_'+hit.recid
            +'" onclick="showDetails(this.id);return false;"><b>' 
            + hit["md-title"] +' </b></a>'); 
	      if (hit["md-title-remainder"] !== undefined) {
	        html.push('<span>' + hit["md-title-remainder"] + ' </span>');
	      }
	      if (hit["md-title-responsibility"] !== undefined) {
    	    html.push('<span><i>'+hit["md-title-responsibility"]+'</i></span>');
      	}
        if (hit.recid == curDetRecId) {
            html.push(renderDetails(curDetRecData));
        }
      	html.push('</div>');
    }
    replaceHtml(results, html.join(''));
}

function my_onstat(data) {
    var stat = document.getElementById("stat");
    if (stat == null)
	return;
    
    stat.innerHTML = '<b> .:STATUS INFO</b> -- Active clients: '
                        + data.activeclients
                        + '/' + data.clients + ' -- </span>'
                        + '<span>Retrieved records: ' + data.records
                        + '/' + data.hits + ' :.</span>';
}

function my_onterm(data) {
    var termlists = [];
    termlists.push('<hr/><b>TERMLISTS:</b><hr/><div class="termtitle">.::Sources</div>');
    for (var i = 0; i < data.xtargets.length && i < SourceMax; i++ ) {
        termlists.push('<a href="#" target_id='+data.xtargets[i].id
            + ' onclick="limitTarget(this.getAttribute(\'target_id\'), this.firstChild.nodeValue);return false;">' + data.xtargets[i].name 
        + ' </a><span> (' + data.xtargets[i].freq + ')</span><br/>');
    }
     
    termlists.push('<hr/><div class="termtitle">.::Subjects</div>');
    for (var i = 0; i < data.subject.length && i < SubjectMax; i++ ) {
        termlists.push('<a href="#" onclick="limitQuery(\'su\', this.firstChild.nodeValue);return false;">' + data.subject[i].name + '</a><span>  (' 
              + data.subject[i].freq + ')</span><br/>');
    }
     
    termlists.push('<hr/><div class="termtitle">.::Authors</div>');
    for (var i = 0; i < data.author.length && i < AuthorMax; i++ ) {
        termlists.push('<a href="#" onclick="limitQuery(\'au\', this.firstChild.nodeValue);return false;">' 
                            + data.author[i].name 
                            + ' </a><span> (' 
                            + data.author[i].freq 
                            + ')</span><br/>');
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
    document.search.query.value = '';
    document.select.sort.onchange = onSelectDdChange;
    document.select.perpage.onchange = onSelectDdChange;
}

// when search button pressed
function onFormSubmitEventHandler() 
{
    resetPage();
    loadSelect();
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

function renderDetails(data, marker)
{
    var details = '<div class="details" id="det_'+data.recid+'"><table>';
    if (marker) details += '<tr><td>'+ marker + '</td></tr>';
    if (data["md-title"] != undefined) {
        details += '<tr><td><b>Title</b></td><td><b>:</b> '+data["md-title"];
  	if (data["md-title-remainder"] !== undefined) {
	      details += ' : <span>' + data["md-title-remainder"] + ' </span>';
  	}
  	if (data["md-title-responsibility"] !== undefined) {
	      details += ' <span><i>'+ data["md-title-responsibility"] +'</i></span>';
  	}
 	  details += '</td></tr>';
    }
    if (data["md-date"] != undefined)
        details += '<tr><td><b>Date</b></td><td><b>:</b> ' + data["md-date"] + '</td></tr>';
    if (data["md-author"] != undefined)
        details += '<tr><td><b>Author</b></td><td><b>:</b> ' + data["md-author"] + '</td></tr>';
    if (data["md-electronic-url"] != undefined)
        details += '<tr><td><b>URL</b></td><td><b>:</b> <a href="' + data["md-electronic-url"] + '" target="_blank">' + data["md-electronic-url"] + '</a>' + '</td></tr>';

    var len=data["location"].length;
    for (var i=0; i<len; i++) {

	details += '<tr><td>&nbsp;</td><td><hr/></td><td>&nbsp;</td></tr>';
	if (data["location"][i]["md-medium"] != undefined)
	    details += '<tr><td><b>Medium</b></td><td><b>:</b> ' + data["location"][i]["md-medium"] + '</td></tr>';
	if (data["location"][i]["md-subject"] != undefined)
            details += '<tr><td><b>Subject</b></td><td><b>:</b> ' + data["location"][i]["md-subject"] + '</td></tr>';
	if (data["location"][i]["@name"] != undefined)
            details += '<tr><td><b>Location</b></td><td><b>:</b> ' + data["location"][i]["@name"] + " (" +data["location"][i]["@id"] + ")" + '</td></tr>';

	if (data["location"][i]["@name"] == 'South Central Regional Library (Evergreen)')
	    details += '<tr><td><b>Login</b></td><td><b>:</b> ' + '<a href="https://hume.uwinnipeg.ca/opac/en-CA/skin/default/xml/myopac.xml?ol=102&t=ducks&tp=keyword&l=102&d=2" target="_blank">South Central Regional Library</a>'  + '</td></tr>';

// Doesn't work:
//	if (data["location"][0]["@requestby"] == 'Login')
//	    details += '<tr><td><b>Login</b></td><td><b>:</b> ' + '<a href="' + data["location"][0]["@requesturl"] + '" target="_blank">' + data["location"][0]["@name"] + '</a>'  + '</td></tr>';

	if (data["location"][i]["md-requestby"] != undefined) {
	    if (data["location"][i]["md-requestby"] == 'Login') {
		if (data["location"][i]["md-requesturl"] != undefined) {
		    details += '<tr><td><b>requesturl</b></td><td><b>:</b> ' + '<a href="' + data["location"][i]["md-requesturl"] + '" target="_blank">' + data["location"][i]["md-requesturl"] + '</a>'  + '</td></tr>';
		} else {
		    details += '<tr><td><b>via email</b></td><td><b>:</b> ' + 'some.url.goes.here' + '</td></tr>';
		}
	    } else {  // Email
		if (data["location"][i]["md-requesturl"] != undefined) {
		    details += '<tr><td><b>requesturl</b></td><td><b>:</b> ' + '<a href="' + data["location"][i]["md-requesturl"] + '?subject=ILL Request&amp;body=Library X would like to request the title:%0A%0A' + data["md-title"] + '%0A%0A from ' + data["location"][i]["@name"] + '." target="_blank">' + data["location"][i]["md-requesturl"] + '</a>'  + '</td></tr>';
		} else {
		    details += '<tr><td><b>via email</b></td><td><b>:</b> ' + 'some.url.goes.here' + '</td></tr>';
		}
	    }
	} // end of request-by
    }

    details += '</table></div>';
    return details;
}
 //EOF
