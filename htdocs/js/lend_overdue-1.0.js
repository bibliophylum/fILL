// lend_overdue.js
/*
    fILL - Free/Open-Source Interlibrary Loan management system
    Copyright (C) 2012  Government of Manitoba

    lend_overdue.js is a part of fILL.

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

    $.getJSON('/cgi-bin/get-lend-overdue-list.cgi', {oid: $("#oid").text()},
            function(data){
                //alert (data.overdue[0].id+" "+data.overdue[0].title+" "+data.overdue[0].author+" "+data.overdue[0].ts+" "+data.overdue[0].due_date+" "+data.overdue[0].patron_barcode); //further debug
                build_table(data);

                $('#overdue-table').DataTable({
                       "jQueryUI": true,
                       "pagingType": "full_numbers",
                       "info": true,
                       "ordering": true,
		       "order": [[3,"asc"]],
                       "dom": '<"H"Tfr>t<"F"ip>',
                       // TableTools requires Flash version 10...
	               "tableTools": {
                           "sSwfPath": "/plugins/DataTables-1.10.2/extensions/TableTools/swf/copy_csv_xls_pdf.swf",
		           "aButtons": [
			      "copy", "csv", "xls", "pdf", "print",
			      {
				"sExtends":    "collection",
				"sButtonText": "Save",
				"aButtons":    [ "csv", "xls", "pdf" ]
			      }
		           ]
        	       },
                       "columnDefs": [ {
                           "targets": [0,1,2,4],
                           "visible": false
                       } ],
                      "initComplete": function() {
                          // this handles a bug(?) in this version of datatables;
                          // hidden columns caused the table width to be set to 100px, not 100%
                          $("#overdue-table").css("width","100%");
                      }
                  });
           });

    $(function() {
           update_menu_counters( $("#oid").text() );
    });

});

function build_table( data ) {
    //alert( 'in build_table' );
    var myTable = document.createElement("table");
    myTable.setAttribute("id","overdue-table");
    myTable.className = myTable.className + " row-border";
    var tHead = myTable.createTHead();
    var row = tHead.insertRow(-1);
    var cell;
    // Can't just use:
    // cell = row.insertCell(-1); cell.innerHTML = "ID";
    // ...because insertCell inserts TD elements, and our CSS uses TH for header cells.
    
    cell = document.createElement("TH"); cell.innerHTML = "gid"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "cid"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "ID"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Loaned to"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Loaned to (ID)"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Title"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Author"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Last update"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Status"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Due date"; row.appendChild(cell);
    cell = document.createElement("TH"); cell.innerHTML = "Email (if you use web-based email, right-click the address to open in a new tab)"; row.appendChild(cell);
    
    var tFoot = myTable.createTFoot();
    row = tFoot.insertRow(-1);
    cell = row.insertCell(-1); cell.colSpan = "11"; cell.innerHTML = "These items are now overdue.<br/><br/>If you use a web-based email client, such as GMail or Hotmail, right-click the email address to open your email client in a new tab.<br/>If you use a stand-alone email client, such as Outlook or Thunderbird, you can just click on the email address.";
    
    // explicit creation of TBODY element to make IE happy
    var tBody = document.createElement("TBODY");
    myTable.appendChild(tBody);
    
    for (var i=0;i<data.overdue.length;i++) 
    {
        row = tBody.insertRow(-1); row.id = 'req'+data.overdue[i].id;
        cell = row.insertCell(-1); cell.innerHTML = data.overdue[i].gid;
        cell = row.insertCell(-1); cell.innerHTML = data.overdue[i].cid;
        cell = row.insertCell(-1); cell.innerHTML = data.overdue[i].id;
        cell = row.insertCell(-1); cell.innerHTML = data.overdue[i].borrower_symbol; cell.setAttribute('title', data.overdue[i].library);
        cell = row.insertCell(-1); cell.innerHTML = data.overdue[i].msg_to;
        cell = row.insertCell(-1); cell.innerHTML = data.overdue[i].title;
        cell = row.insertCell(-1); cell.innerHTML = data.overdue[i].author;
        cell = row.insertCell(-1); cell.innerHTML = data.overdue[i].ts;
        cell = row.insertCell(-1); cell.innerHTML = data.overdue[i].status;
        cell = row.insertCell(-1); cell.innerHTML = data.overdue[i].due_date;
        cell = row.insertCell(-1); cell.innerHTML = '<a href="mailto:'+data.overdue[i].email_address+'?subject=Overdue:+'+data.overdue[i].title+'&body=The+title+%22'+data.overdue[i].title+'%22,+borrowed+from+'+data.overdue[i].lending_library+',+was+due+on+'+data.overdue[i].due_date+'.%0D%0A%0D%0AIf+you+have+already+returned+this+title,+please+mark+it+as+%22Returned%22+in+fILL.%0D%0A%0D%0AThank+you">'+data.overdue[i].email_address+'</a>';
    }
    
    document.getElementById('mylistDiv').appendChild(myTable);
    
    $("#waitDiv").hide();
    $("#mylistDiv").show();
}

