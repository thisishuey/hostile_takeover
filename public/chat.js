// Generated by CoffeeScript 1.7.1
var htmlEntities, name, pageTitleNotification;

name = '&lt;anon&gt;';

htmlEntities = function(string) {
  return String(string).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
};

pageTitleNotification = {
  vars: {
    originalTitle: document.title,
    interval: null
  },
  on: function(notification, intervalSpeed) {
    var that;
    if (intervalSpeed == null) {
      intervalSpeed = 1000;
    }
    that = this;
    that.vars.interval = setInterval(function() {
      return document.title = that.vars.originalTitle === document.title ? notification : that.vars.originalTitle;
    }, intervalSpeed);
    return true;
  },
  off: function() {
    clearInterval(this.vars.interval);
    document.title = this.vars.originalTitle;
    return true;
  }
};

$(function() {
  var $content, $field, $joinButton, $joinGame, $name, $playGame, $sendButton, $username, $window, joinGame, messages, sendMessage, socket, windowFocus;
  $window = $(window);
  windowFocus = true;
  socket = io.connect(window.location.origin);
  messages = [];
  $joinGame = $('#join-game');
  $username = $('#username');
  $joinButton = $('#join');
  $playGame = $('#play-game');
  $content = $('#content');
  $name = $('#name');
  $field = $('#field');
  $sendButton = $('#send');
  $window.focus(function() {
    windowFocus = true;
    pageTitleNotification.off();
    return true;
  });
  $window.blur(function() {
    windowFocus = false;
    return true;
  });
  socket.on('message', function(data) {
    var html, i, _i, _ref;
    if (data.message) {
      messages.push(data);
      html = '';
      for (i = _i = 0, _ref = messages.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
        html += "<strong>" + (htmlEntities(messages[i].username ? messages[i].username : 'Server')) + ":</strong> ";
        html += "" + (htmlEntities(messages[i].message)) + "<br>";
      }
      $content.html(html);
      $content.scrollTop($content[0].scrollHeight);
      if (data.username && data.username !== $name.val() && !windowFocus) {
        pageTitleNotification.on(data.username + " says " + data.message, 1500);
      }
    } else {
      console.log("There is a problem: " + data);
    }
    return true;
  });
  joinGame = function() {
    if ($username.val() === '') {
      alert('Please type your name!');
    } else {
      name = $username.val();
      $name.html(name);
      socket.emit('send', {
        message: "" + name + " just joined the chat"
      });
      $joinGame.collapse('hide');
      $playGame.collapse('show');
      $field.trigger('focus');
    }
    return true;
  };
  $joinButton.on('click', function(event) {
    joinGame();
    return true;
  });
  $username.on('keydown', function(event) {
    if (event.keyCode === 13) {
      joinGame();
    }
    return true;
  });
  sendMessage = function() {
    var text;
    if (name === '') {
      alert('Please type your name!');
    } else {
      text = $field.val();
      socket.emit('send', {
        username: name,
        message: text
      });
      $field.val('');
    }
    return true;
  };
  $sendButton.on('click', function(event) {
    sendMessage();
    return true;
  });
  $field.on('keydown', function(event) {
    if (event.keyCode === 13) {
      sendMessage();
    }
    return true;
  });
  $username.trigger('focus');
});
