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
function i18n_setText() {
    if ((typeof langDataRaw === "undefined") || (!langDataRaw)) {
	alert('This page needs to be i18n-ized.');
    } else {
	langData = jQuery.parseJSON( langDataRaw );
	for (var elementID in langData) {
	    if (langData.hasOwnProperty(elementID)) {
		//alert(elementID+':'+langData[elementID]);
		$("#"+elementID).text( langData[elementID] );
	    }
	}
    }
}

// An object property name can be any valid JavaScript string, or anything that
// can be converted to a string, including the empty string. However, any property
// name that is not a valid JavaScript identifier (for example, a property name
// that has a space or a hyphen, or that starts with a number) can only be accessed
// using the square bracket notation.
// https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Working_with_Objects#Objects_and_properties


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
	    url+='&language='+newLang
	}
	//console.debug('New URL: '+url+'\n----------------------');
	// As an HTTP redirect:
	window.location.replace(url);
	// As a link click:
	//window.location.href = url;
    }
}
