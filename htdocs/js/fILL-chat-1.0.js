// fILL-chat.js
/*
    fILL - Free/Open-Source Interlibrary Loan management system
    Copyright (C) 2012  Government of Manitoba

    fILL-chat.js is a part of fILL.

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

var connections;

function Channel( channel ) {
    //create a new WebSocket object.
    var wsUri = "wss://localhost/app/ws/";  
    var websocket = new WebSocket(wsUri);
    websocket.onmessage = function(ev){ wsOnMessage(ev, channel) };
    websocket.onopen    = function(ev){ wsOnOpen(ev, channel) };
    websocket.onerror   = function(ev){ wsOnError(ev, channel) };
    websocket.onclose   = function(ev){ wsOnClose(ev, channel) };

    this.name = channel;
    this.color = "808080";
    this.ws = websocket;
}

//------------------------------------------------------------------------------
// instance methods
//    

Channel.prototype.send = function (message, callback) {
    var self = this;
    this.waitForConnection(function () {
	//alert("Connection ok, sending ["+message+"]");
        self.ws.send(message);  // use the ws send()
	//alert("Sent.");
        if (typeof callback !== 'undefined') {
          callback();
        }
    }, 1000);
};

Channel.prototype.waitForConnection = function(callback, interval) {
    if (this.ws.readyState === 1) {
        callback();
    } else {
        var that = this;
        setTimeout(function () {
            that.waitForConnection(callback);
        }, interval);
    }
};

Channel.prototype.sendJoiningMessage = function() {
    // Send a "joining" message JUST so we can get history
    var msg = {
      message: "joining",
      name: $("#username").text(),
      lid: $("#lid").text(),
      color: this.color,
      channel: this.name
    };

    //convert and send data to server
    this.send(JSON.stringify(msg));    // NOT this.ws.send(...)
};

Channel.prototype.chatSendMsg = function(){         //user clicks message send button  
    var mymessage = $('#input-'+this.name).val();
    var myname = $("#username").text();
    var mylid = $("#lid").text();
    var mycolor = this.color;
    var channel = this.name;

    //alert("chatSendMsg: message ["+mymessage+"], channel ["+channel+"]");

    if(mymessage == ""){ //emtpy message?
        alert("Enter Some message Please!");
        return;
    }
       
    //prepare json data
    var msg = {
      message: mymessage,
      name: myname,
      color: mycolor,
      channel: channel
    };
    //convert and send data to server
    this.send(JSON.stringify(msg));  // NOT this.ws.send(...)
};



//------------------------------------------------------------------------------
// websocket callbacks
//    
function wsOnOpen(ev, channel) {
    //notify user
    $('#messages-'+channel).append("<div class=\"system_msg\">"+connections[channel].name+" Connected!</div>");
}

//#### Message received from server?
function wsOnMessage(ev, channel) {
    var msg = JSON.parse(ev.data); //chat-server.pl sends JSON data
    var type = msg.type; //message type
    var umsg = msg.message; //message text
    var uname = msg.name; //user name
    var ucolor = msg.color; //color

    //-------------------------------------------------------------------
    if (type == 'usermsg') {
        $("#messages-"+channel).append(
	    "<div><span class=\"user_name\" style=\"color:#"+ucolor+"\">"+uname+"</span> : <span class=\"user_message\">"+umsg+"</span></div>"
	);
    }

    //-------------------------------------------------------------------
    if (type == 'close') {
	// note: if the same patron re-opens chat before the librarian
	// has closed the window, bad things happen.  FIXME!

	$("#chat-entry-"+channel).toggle(); // hide the input controls

	$("<input/>", 
	  {id:"close-btn-"+channel,
	   type: "button",
	   value: "Close"
	  }).appendTo($("#"+channel));

	$("#close-btn-"+channel).on( "click", function() {
	    $("#"+channel).remove();
	    // remove from connections:
	    //var index = array.indexOf(channel); // not supported in IE8 or lower!
	    var index = $.inArray(channel, connections); // yay for jQuery!
	    if (index > -1) {
		connections.splice(index, 1);
	    }
	});
    };

    //-------------------------------------------------------------------
    if (type == 'color') {
	// server sent a color assignment
	connections[umsg].color = ucolor;
    };

    //-------------------------------------------------------------------
    if (type == 'open') {  // server asking us to open a new channel
	var newChannel = umsg;  // chat server gives channel name in umsg

        // open new connection
	connections[newChannel] = new Channel(newChannel); 

	// create a new message box with the id of the channel
	var $div = $("<div/>", 
		     {id: newChannel, 
		      class: "single-channel",
//		      style: "border:1px solid; float: left; width:300px; background-color:yellow;"
		     }).appendTo("#channels");
	$("#"+newChannel).append(
	    "<div class=\"channel-title\"><h2>"+newChannel+"</h2></div>"
	);
	$("#"+newChannel).append(
	    "<div class=\"messages\" id=\"messages-"+newChannel+"\"></div>"
	);
	var $chatEntry = $("<div/>",
			   {id: "chat-entry-"+newChannel,
			    class: "chat-entry"
			   }).appendTo($div);
	$("<input/>",
	  {type: "text",
	   name: "message",
	   id: "input-"+newChannel,
	   class: "chat-input",
	   maxlength: 80
	  }).appendTo($chatEntry);

	$("<input/>", 
	  {id:"send-btn-"+newChannel,
	   type: "button",
	   class: "library-style",
	   value: "Send"
	  }).appendTo($chatEntry);

	$("#send-btn-"+newChannel).on( "click", function() {
	    connections[newChannel].chatSendMsg();
	    $("#input-"+newChannel).val("");
	    $("#input-"+newChannel).focus();
	});
	
	$("#input-"+newChannel).keypress(function (e) {
            if (e.which == 13) {
		$("#send-btn-"+newChannel).click();
		return false;  // have jQuery call e.preventDefault() and e.stopPropagation()
            }
	});

        // get the history for the new ws
        connections[newChannel].sendJoiningMessage();

    }
       
    $('#message').val(''); //reset text
};
   
function wsOnError(ev, channel) { 
    $('#messages-'+channel).append("<div class=\"system_error\">Error Occurred - "+ev.data+"</div>");
};

function wsOnClose(ev, channel) {
    $('#messages-'+channel).append("<div class=\"system_msg\">Connection Closed</div>");
};



//------------------------------------------------------------------------------
// util
//    

// https://stackoverflow.com/questions/321113/how-can-i-pre-set-arguments-in-javascript-function-call-partial-function-appli
function partial(func /*, 0..n args */) {
  var args = Array.prototype.slice.call(arguments, 1);
  return function() {
    var allArguments = args.concat(Array.prototype.slice.call(arguments));
    return func.apply(this, allArguments);
  };
}

