// Generated by CoffeeScript 1.7.1
var htmlEntities, name, pageTitleNotification;

name = '';

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
  var $content, $field, $gainCredButton, $joinButton, $joinGame, $loseCredButton, $name, $playGame, $sendButton, $startButton, $startGame, $username, $window, joinGame, logs, selfIndex, sendMessage, socket, windowFocus;
  $window = $(window);
  windowFocus = true;
  socket = io.connect(window.location.origin);
  logs = [];
  $joinGame = $('#join-game');
  $username = $('#username');
  $joinButton = $('#join');
  selfIndex = -1;
  $startGame = $('#start-game');
  $startButton = $('#start');
  $playGame = $('#play-game');
  $content = $('#content');
  $name = $('#name');
  $field = $('#field');
  $sendButton = $('#send');
  $gainCredButton = $('#gainCredibility');
  $loseCredButton = $('#loseCredibility');
  $window.on('focus', function(event) {
    windowFocus = true;
    pageTitleNotification.off();
    return true;
  });
  $window.on('blur', function(event) {
    windowFocus = false;
    return true;
  });
  $gainCredButton.on('click', function(event) {
    increaseCredibility(selfIndex, 1);
    return true;
  });
  $loseCredButton.on('click', function(event) {
    decreaseCredibility(selfIndex, 1);
    return true;
  });
  socket.on('message', function(data) {
    var $message, text, username;
    if (data == null) {
      data = {};
    }
    if (data.message) {
      logs.push(data);
      username = data.username ? data.username : 'Server';
      text = data.message;
      $message = $('<div>', {
        "class": 'message'
      });
      $message.append($('<strong>', {
        html: "" + username + ": "
      }));
      $message.append(text);
      $content.append($message);
      $content.scrollTop($content.prop('scrollHeight'));
      if (data.username && username !== name && !windowFocus) {
        pageTitleNotification.off();
        pageTitleNotification.on("" + username + " says " + text, 1500);
      }
    } else {
      console.log("There is a problem: " + data);
    }
    return true;
  });
  socket.on('game:start', function(data) {
    var $emptyPanels;
    if (data == null) {
      data = {};
    }
    $emptyPanels = $('.panel-empty');
    $emptyPanels.css('opacity', 0.25);
    $startGame.collapse('hide');
    $playGame.collapse('show');
    $field.trigger('focus');
    return true;
  });
  socket.on('board:update', function(data) {
    var $player, $playerCards, $playerCredibility, $playerPanel, $playerTitle, activeSelector, card, cardIndex, player, playerIndex, players, _ref;
    if (data == null) {
      data = {};
    }
    if (data.players) {
      players = data.players;
      activeSelector = data.activeSelector || false;
      for (playerIndex in players) {
        player = players[playerIndex];
        if (selfIndex < 0 && player.name === name) {
          selfIndex = playerIndex;
        }
        $player = $("#player-" + playerIndex);
        $playerPanel = $player.find('.panel');
        $playerTitle = $player.find('.panel-title');
        $playerCards = [$player.find('.card-0'), $player.find('.card-1')];
        $playerCredibility = $player.find('.credibility');
        $playerPanel.prop('class', 'panel panel-default');
        $playerTitle.html(player.name);
        _ref = player.cards;
        for (cardIndex in _ref) {
          card = _ref[cardIndex];
          $playerCards[cardIndex].prop('src', card);
        }
        $playerCredibility.html("" + player.credibility + " Credibility");
      }
      if (activeSelector !== false) {
        $playerPanel = $("" + activeSelector + " .panel");
        $playerPanel.prop('class', 'panel panel-primary');
      }
      if (players.length < 2) {
        return $startButton.prop('disabled', true);
      } else {
        return $startButton.prop('disabled', false);
      }
    }
  });
  joinGame = function() {
    if ($username.val() === '') {
      alert('Please enter your name!');
    } else {
      name = htmlEntities($username.val());
      $name.html(name);
      socket.emit('send', {
        message: "<em>" + name + " joined the game</em>"
      });
      socket.emit('game:join', {
        name: name
      });
      $joinGame.collapse('hide');
      $startGame.collapse('show');
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
  $startButton.on('click', function(event) {
    socket.emit('game:start');
    return true;
  });
  sendMessage = function() {
    var text;
    if ($field.val() === '') {
      alert('Please enter a message!');
    } else {
      text = htmlEntities($field.val());
      socket.emit('send', {
        username: name,
        message: text
      });
      $field.val('');
      $field.trigger('focus');
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
  socket.emit('game:reset');
});
