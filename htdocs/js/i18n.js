// i18n.js
/*
    fILL - Free/Open-Source Interlibrary Loan management system
    Copyright (C) 2012  Government of Manitoba

    i18n.js is a part of fILL.

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

//------------------------------------------------------------------------
function i18n_load() {
    var page;
    if ( $("#template").length === 1 ) {
	page = $("#template").text();
    } else {
	// This can all go away once all CGI::App modules are passing the
	//   'template' parameter.

	// my javascript regex-fu is bad... we want to turn something like:
	//   .../public.cgi?rm=test_form&language=en
	// into:
	//   public/test.tmpl
	
	var pathname = window.location.pathname;
	page = pathname.substring( pathname.lastIndexOf('/') + 1 );
	page = page.substr(0, page.indexOf('.')); // remove ".cgi"

	var parameters = window.location.search.substring(1); // remove leading '?'
	var rm = parameters.replace(/^.*rm=(.*)/, '$1');
	if (rm.indexOf('&') > 0) {
	    rm = rm.substr(0, rm.indexOf('&')); // remove any additional parms
	}
	if (rm.indexOf('_') > 0) {
	    rm = rm.substr(0, rm.indexOf('_')); // remove any "_form"
	}
	
	page = page+'/'+rm+'.tmpl';
    }

    // the public-header-functions attempt to refresh the #language selectmenu
    // may happen *before* the .getJSON for i18n.cgi completes, so we need to
    // pre-setup the element as a jQuery UI selectmenu:
    $("#language").selectmenu({
        change: i18n_select_change,
        width : 150
    });
    
    var language = document.documentElement.lang;
    var parms = {
	"page": page,
	"lang": language
    }

    $.getJSON('/cgi-bin/i18n.cgi', parms,
              function(data){
		  var languageData = data.i18n.js_lang_data;
		  for (var elementID in languageData) {
		      if (languageData.hasOwnProperty(elementID)) {
			  var stage = null;
			  var whatToChange = null;
			  
			  if (languageData[elementID].hasOwnProperty('constant')) {
			      stage = 'constant';
			      whatToChange = languageData[elementID]['constant'].change;
			  } else if (languageData[elementID].hasOwnProperty('initial')) {
			      stage = 'initial';
			      whatToChange = languageData[elementID]['initial'].change;
			  }

			  if (whatToChange) {
			      if (whatToChange === 'text') {
				  $('#'+elementID).text(
				      languageData[elementID][stage].translation
				  );
				  
			      } else if (whatToChange === 'attr') {
				  $('#'+elementID).attr(
				      languageData[elementID][stage].which,
				      languageData[elementID][stage].translation
				  );

			      } else if (whatToChange === 'prop') {
				  $('#'+elementID).prop(
				      languageData[elementID][stage].which,
				      languageData[elementID][stage].translation
				  );

			      }
			  }

		      }
		  }
		  // some pages need ongoing access to the translation data.  They need
		  // to declare the global variable i18n_data, and set it's value to
		  // something (e.g. 'data goes here').
		  if (typeof i18n_data !== 'undefined') {
		      i18n_data = languageData;
		  }

		  // similarly, if a page contains DataTable()s which have translations
		  // for column headings.  They need to declare the global variable
		  // i18n_tables, and set it's value to something (e.g. 'data goes here').
		  if (typeof i18n_tables !== 'undefined') {
		      i18n_tables = data.i18n.tabledef;
		  }

	      })
	.success(function(data) {
	    //i18n_table_column_headings();
        })
	.error(function(data) {
	    alert('Error loading ['+parms.lang+'] language data for ['+parms.page+'] template.');
        })
	.complete(function() {
	    i18n_language_changer(); // make sure the language-changer uses correct langs
        });
}

// NOTE to self:
// An object property name can be any valid JavaScript string, or anything that
// can be converted to a string, including the empty string. However, any property
// name that is not a valid JavaScript identifier (for example, a property name
// that has a space or a hyphen, or that starts with a number) can only be accessed
// using the square bracket notation.
// https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Working_with_Objects#Objects_and_properties


//------------------------------------------------------------------------
function i18n_table_column_headings(tableId) {
    // pages with DataTables must have i18n_data defined; it will get the translation
    // data assigned to it so that it can be accessed here

    if (typeof i18n_tables !== 'undefined') {                  // do we want DataTables?
	var $tbl = $(tableId);
	if ( $.fn.DataTable.isDataTable( $tbl ) ) {            // is it a DataTable()?
	    var keyPrefix = $tbl.attr('id')+'-col-';           // only want to look at
	    for (var key in i18n_tables) {                     //   this table's i18n
		if (i18n_tables.hasOwnProperty(key)) {
		    if (key.indexOf(keyPrefix) !== -1) {
			var c = parseInt( key.slice(keyPrefix.length) );   // get col#
			$($tbl.DataTable().column(c).header()).text( i18n_tables[key] );
		    }
		}
	    }
	}
    }
}

//------------------------------------------------------------------------
// This would have to happen after ALL DataTables on the page have
// FINISHED initializing....
//------------------------------------------------------------------------
function i18n_all_table_column_headings() {
    // pages with DataTables must have i18n_data defined; it will get the translation
    // data assigned to it so that it can be accessed here

    if (typeof i18n_tables !== 'undefined') {                  // do we want DataTables?
	$("table").each( function(){                           // check each table on page
	    if ( $.fn.DataTable.isDataTable( $(this) ) ) {     // is it a DataTable()?
		var keyPrefix = this.id+'-col-';               // only want to look at
		for (var key in i18n_tables) {                 //   this table's i18n
		    if (i18n_tables.hasOwnProperty(key)) {
			if (key.indexOf(keyPrefix) !== -1) {
			    var c = parseInt( key.slice(keyPrefix.length) );   // get col#
			    var tbl = $(this).DataTable();
			    $(tbl.column(c).header()).text( i18n_tables[key] );
			}
		    }
		}
	    }
	});
    }
}

//------------------------------------------------------------------------
function i18n_code2language( lang ) {
    var language;
    if (lang === 'en') { language = 'English'; }
    else if (lang === 'fr') { language = 'Français'; }
    else { language = 'English' } // default
    return language;
}


// also: ui.item.index
//------------------------------------------------------------------------
function i18n_select_change( event, ui ) {
    var currLang = document.documentElement.lang;

    var newLang;
    if (ui.item.value == 'English')       { newLang = 'en';  }
    else if (ui.item.value == 'Français') { newLang = 'fr';  }
    else { newLang = 'en'; }

    $.cookie('fILL-language', newLang, { expires:365, path: '/' });

    //console.debug('currLang ['+currLang+'], newLang ['+newLang+']');
    if (newLang !== currLang) {
	var url = window.location.href;
	if (url.indexOf('language=') >= 0) {
	    //console.debug('Found language in URL');
	    var re = /language=[a-z]{2}/;
	    url = url.replace(re, 'language='+newLang);
	} else {
	    //console.debug('No language in URL');
	    if (url.indexOf('?') >= 0) { // existing parms
		url+='&language='+newLang;
	    } else {                    // no other parms
		url+='?language='+newLang;
	    }
	}
	//console.debug('New URL: '+url+'\n----------------------');
	// As an HTTP redirect:
	window.location.replace(url);
	// As a link click:
	//window.location.href = url;
    }
}

//------------------------------------------------------------------------
function i18n_language_changer() {
    var options = [];

    // Clear the options first   
    $("#language option").each(function(index, option) {
        $(option).remove();
    });
    options.push("<option lang='en' value='English'>English</option>");
    options.push("<option lang='fr' value='Français'>Français</option>");

    $('#language').append(options.join("")).selectmenu({
        change: i18n_select_change,
        width : 150
    });
    var language = i18n_code2language( document.documentElement.lang );
    $("#language").val( language );
    
    $('#language').selectmenu('refresh');
}
