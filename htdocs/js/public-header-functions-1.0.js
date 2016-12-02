// public-header-functions.js
/*
    fILL - Free/Open-Source Interlibrary Loan management system
    Copyright (C) 2012  Government of Manitoba

    public-header-functions.js is a part of fILL.

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

$('document').ready(function(){
    
    i18n_load();
    
    setFontSizeFromCookies();
    
    $('#incrFont').click(function () {
        ga('send', 'event', 'Font-size', 'increase');
        increaseFontSize();
    });
    $('#decrFont').click(function () {
        ga('send', 'event', 'Font-size', 'decrease');
        decreaseFontSize();
    });
    $('#resetFont').click(function () {
        ga('send', 'event', 'Font-size', 'reset');
        resetFontSizeToDefault();
    });

    if (! $.cookie("fILL-oid")) {
        $.cookie("fILL-oid", $("#oid").text(), { expires: 365, path: '/' });
        //$.cookie("fILL-location", xxx, { expires: 365, path: '/' });
    }

    $("#startOver").on("click",function(e){
        e.preventDefault();
        $.removeCookie("fILL-oid", { path: '/' });
        $.removeCookie("fILL-location", { path: '/' });
        $.removeCookie("fILL-barcode", { path: '/' });
        $.removeCookie("fILL-authentication", { path: '/' });
        $.removeCookie("fILL-language", { path: '/' });
        $("#breadcrumbs").hide();
        $("#extAuth").hide();
        $("#fILLAuth").hide();
        $("#sign-in").hide();
        $(".login-footer").append("<p>Starting over...</p>");
        window.location.href="/cgi-bin/public.cgi";
    });
    $("#clearCookies").on("click",function(e){
        e.preventDefault();
        $.removeCookie("fILL-oid", { path: '/' });
        $.removeCookie("fILL-location", { path: '/' });
        $.removeCookie("fILL-barcode", { path: '/' });
        $.removeCookie("fILL-authentication", { path: '/' });
        $.removeCookie("fILL-language", { path: '/' });
        window.location.href="?authen_logout=1";
    });

    if (typeof $.cookie('fILL-language') != 'undefined') {
        var lang = $.cookie('fILL-language');
        lang = i18n_code2language( lang );
        $("#language").val( lang );
        $("#language").selectmenu('refresh').trigger("selectmenuchange");
    }

    // let us know if we're on production/testing/development
    if (window.location.hostname == 'rigel.gotdns.org') {
	$("#localdev").show();
    }
    if (window.location.hostname == 'fill-dev.mb.libraries.coop') {
	$("#filldev").show();
    }
});

//----------------------------------------------------------------------------
function set_primary_tab(tab_id) {
    document.getElementById(tab_id).className='current_tab';
}

function set_secondary_tab(tab_id) {
    document.getElementById(tab_id).className='current_tab';
}

function increaseFontSize() {
    $('body').find('div, h1, h2, h3, p, td').each(function () {
        var fs = parseFloat($(this).css('font-size')) + 1;  // gets converted to px
        $(this).css({
            'font-size': fs + "px"
        });
        $.cookie('fILL-fontsize-'+$(this)[0].tagName, fs, { expires: 365, path: '/' });
    });
}

function decreaseFontSize() {
    $('body').find('div, h1, h2, h3, p, td').each(function () {
        var fs = parseFloat($(this).css('font-size')) - 1;
        $(this).css({
            'font-size': fs + "px"
        });
        $.cookie('fILL-fontsize-'+$(this)[0].tagName, fs, { expires: 365, path: '/' });
    });
}

function resetFontSizeToDefault() {
    $('body').find('div, h1, h2, h3, p, td').each(function () {
        if (typeof $.cookie('fILL-fontsize-'+$(this)[0].tagName) != 'undefined') {
            $.removeCookie('fILL-fontsize-'+$(this)[0].tagName, { expires: 365, path: '/' });
        }
    });
    location.reload();
} 

function setFontSizeFromCookies() {
    $('body').find('div, h1, h2, h3, p, td').each(function () {
        if (typeof $.cookie('fILL-fontsize-'+$(this)[0].tagName) != 'undefined') {
            var fs = $.cookie('fILL-fontsize-'+$(this)[0].tagName);
            $(this).css({
                'font-size': fs + "px"
            });
        }
    });
} 

