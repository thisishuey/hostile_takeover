// Generated by CoffeeScript 1.7.1
var actions, cardPositions, cards, currentAction, htmlEntities, name, pageTitleNotification, selfIndex, stripTags, _base;

name = '';

selfIndex = -1;

currentAction = false;

actions = {
  income: {
    title: 'Income',
    text: 'takes <strong class="text-success">Income</strong>'
  },
  stock_options: {
    title: 'Stock Options',
    text: 'takes <strong class="text-success">Stock Options</strong>'
  },
  downsize: {
    title: 'Downsize',
    target: true,
    text: 'performs <strong class="text-success">Downsize</strong> on'
  },
  dividends: {
    title: 'Dividends',
    text: 'takes <strong class="text-success">Dividends</strong>'
  },
  block_stock_options: {
    title: 'Block Stock Options',
    target: true,
    text: 'blocks <strong class="text-danger">Stock Options</strong> on'
  },
  steal: {
    title: 'Steal',
    target: true,
    text: '<strong class="text-success">Steals</strong> from'
  },
  block_steal_one_upper: {
    title: 'Block Steal (One-Upper)',
    target: true,
    text: '<strong class="text-danger">Blocks Steal (One-Upper)</strong> from'
  },
  exchange: {
    title: 'Exchange',
    text: '<strong class="text-success">Exchanges</strong> cards'
  },
  block_steal_vp: {
    title: 'Block Steal (VP)',
    target: true,
    text: '<strong class="text-danger">Blocks Steal (VP)</strong> from'
  },
  fire: {
    title: 'Fire',
    target: true,
    text: '<strong class="text-success">Fires</strong>'
  },
  block_fire: {
    title: 'Block Fire',
    target: true,
    text: '<strong class="text-danger">Blocks Fire</strong> from'
  },
  report_credibility: {
    title: 'Report Credibility',
    credibility: true,
    text: 'now has'
  },
  call_bluff: {
    title: 'Call Bluff',
    target: true,
    text: '<strong class="text-success">Calls Bluff</strong> on'
  },
  bluffed_cfo: {
    title: 'Bluffed CFO',
    text: '<strong class="text-danger">Bluffed CFO</strong>'
  },
  bluffed_one_upper: {
    title: 'Bluffed One-Upper',
    text: '<strong class="text-danger">Bluffed One-Upper</strong>'
  },
  bluffed_vp: {
    title: 'Bluffed VP',
    text: '<strong class="text-danger">Bluffed VP</strong>'
  },
  bluffed_manager: {
    title: 'Bluffed Manager',
    text: '<strong class="text-danger">Bluffed Manager</strong>'
  },
  bluffed_hr: {
    title: 'Bluffed HR',
    text: '<strong class="text-danger">Bluffed HR</strong>'
  },
  resign: {
    title: 'Resign',
    text: 'has <strong class="text-danger">Resigned</strong>'
  },
  hostile_takeover: {
    title: 'Hostile Takeover',
    text: '<strong class="text-success">has WON HOSTILE TAKEOVER!!!</strong>'
  }
};

cardPositions = ['first card', 'second card'];

cards = {
  face_down: {
    title: 'Face Down',
    src: '/images/card_face_down.png'
  },
  cfo: {
    title: 'CFO',
    src: '/images/card_cfo.png'
  },
  one_upper: {
    title: 'One-Upper',
    src: '/images/card_one_upper.png'
  },
  vp: {
    title: 'VP',
    src: '/images/card_vp.png'
  },
  manager: {
    title: 'Manager',
    src: '/images/card_manager.png'
  },
  hr: {
    title: 'HR',
    src: '/images/card_hr.png'
  },
  blank: {
    title: 'Blank',
    src: '/images/card_blank.png'
  }
};

if ((_base = String.prototype).startsWith == null) {
  _base.startsWith = function(s) {
    return this.slice(0, s.length) === s;
  };
}

htmlEntities = function(string) {
  return String(string).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
};

stripTags = function(string) {
  return String(string).replace(/(<([^>]+)>)/ig, "");
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
  var $alterAction, $alterCard, $content, $field, $gainCredButton, $joinButton, $joinGame, $loseCredButton, $name, $playGame, $sendButton, $startButton, $startGame, $target, $username, $window, joinGame, logs, parseCLI, performAction, performCardAction, sendActionMessage, sendCardMessage, sendCredibilityMessage, sendMessage, socket, windowFocus;
  $window = $(window);
  windowFocus = true;
  socket = io.connect(location.origin);
  logs = [];
  $joinGame = $('#join-game');
  $username = $('#username');
  $joinButton = $('#join');
  $startGame = $('#start-game');
  $startButton = $('#start');
  $playGame = $('#play-game');
  $content = $('#content');
  $name = $('#name');
  $field = $('#field');
  $sendButton = $('#send');
  $gainCredButton = $('#gainCredibility');
  $loseCredButton = $('#loseCredibility');
  $alterAction = $('.alter-action');
  $target = $('#target');
  $alterCard = $('.alter-card');
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
    alterCredibility(selfIndex, 1);
    return true;
  });
  $loseCredButton.on('click', function(event) {
    alterCredibility(selfIndex, -1);
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
        html: "" + username + ": ",
        "class": 'text-primary'
      }));
      $message.append(text);
      $content.append($message);
      $content.scrollTop($content.prop('scrollHeight'));
      if (data.username && username !== name && !windowFocus) {
        pageTitleNotification.off();
        pageTitleNotification.on("" + username + ": " + (stripTags(text)), 1500);
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
    $joinGame.collapse('hide');
    $startGame.collapse('hide');
    $playGame.collapse('show');
    $field.trigger('focus');
    return true;
  });
  socket.on('board:update', function(data) {
    var $emptyPanels, $player, $playerCards, $playerCredibility, $playerPanel, $playerTitle, card, cardIndex, player, playerIndex, players, _i, _j, _ref;
    if (data == null) {
      data = {};
    }
    if (data.players) {
      players = data.players;
      if (players.length) {
        for (playerIndex in players) {
          player = players[playerIndex];
          $player = $("#player-" + playerIndex);
          $playerPanel = $player.find('.panel');
          $playerTitle = $player.find('.panel-title');
          $playerCards = [$player.find('.card-0'), $player.find('.card-1')];
          $playerCredibility = $player.find('.credibility');
          if (player.active) {
            $playerPanel.prop('class', 'panel panel-primary');
          } else {
            $playerPanel.prop('class', 'panel panel-default');
          }
          $playerPanel.prop('class', 'panel panel-primary');
          $playerTitle.html(player.name);
          _ref = player.cards;
          for (cardIndex in _ref) {
            card = _ref[cardIndex];
            $playerCards[cardIndex].prop('src', card);
          }
          $playerCredibility.html("" + player.credibility + " Credibility");
          if (selfIndex < 0 && player.name === name) {
            selfIndex = playerIndex;
          }
        }
        if (players.length < 2) {
          return $startButton.prop('disabled', true);
        } else {
          return $startButton.prop('disabled', false);
        }
      } else {
        selfIndex = -1;
        for (playerIndex = _i = 0; _i <= 5; playerIndex = ++_i) {
          $player = $("#player-" + playerIndex);
          $playerPanel = $player.find('.panel');
          $playerTitle = $player.find('.panel-title');
          $playerCards = [$player.find('.card-0'), $player.find('.card-1')];
          $playerCredibility = $player.find('.credibility');
          $playerPanel.prop('class', 'panel panel-empty hidden-xs');
          $playerTitle.html("Player " + (playerIndex + 1));
          for (cardIndex = _j = 0; _j <= 1; cardIndex = ++_j) {
            $playerCards[cardIndex].prop('src', '/images/card_blank.png');
          }
          $playerCredibility.html('0 Credibility');
        }
        $startButton.prop('disabled', true);
        $emptyPanels = $('.panel-empty');
        $emptyPanels.css('opacity', 1.0);
        if (!$joinGame.hasClass('in')) {
          $joinGame.collapse('show');
        }
        if ($startGame.hasClass('in')) {
          $startGame.collapse('hide');
        }
        if ($playGame.hasClass('in')) {
          $playGame.collapse('hide');
        }
        return $username.trigger('focus');
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
    } else if ($field.val().startsWith(":")) {
      parseCLI($field.val());
    } else {
      text = htmlEntities($field.val());
      socket.emit('send', {
        username: name,
        message: text
      });
    }
    $field.val('');
    $field.trigger('focus');
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
  sendCredibilityMessage = function() {
    var credibilityText;
    credibilityText = $("#player-" + selfIndex + " .credibility").text();
    sendActionMessage("has <strong class=\"text-success\">" + credibilityText + "</strong>");
    return true;
  };
  sendActionMessage = function(text, target) {
    if (target == null) {
      target = false;
    }
    socket.emit('send', {
      username: name,
      message: "<em>" + text + "</em>"
    });
    $('#actionsModal').modal('hide');
    return true;
  };
  parseCLI = function(commandString) {
    var commands;
    commands = commandString.split(':');
    commands = $.grep(commands, function(n) {
      return n;
    });
    if (commands.length > 0) {
      switch (commands[0]) {
        case "block":
          if (commands.length > 2) {
            $target.val(commands[2]);
            switch (commands[1]) {
              case "cfo":
              case "stock":
              case "stock_options":
                performAction("block_stock_options");
                break;
              case "1up":
              case "steal1up":
                performAction("block_steal_one_upper");
                break;
              case "vp":
              case "stealvp":
                performAction("block_steal_vp");
                break;
              case "hr":
              case "fire":
                performAction("block_fire");
            }
          }
          break;
        case "bs":
          if (commands.length > 1) {
            $target.val(commands[1]);
            performAction("call_bluff");
          }
          break;
        case "card":
          if (commands.length > 2) {
            performCardAction(parseInt(commands[1] - 1, 10), commands[2]);
          }
          break;
        case "cred":
          if (commands.length === 1) {
            sendCredibilityMessage();
          } else {
            alterCredibility(selfIndex, parseInt(commands[1], 10));
          }
          break;
        case "dividends":
        case "tax":
          performAction("dividends");
          alterCredibility(selfIndex, 3);
          break;
        case "downsize":
        case "coup":
          if (commands.length > 1) {
            $target.val(commands[1]);
            performAction("downsize");
          }
          break;
        case "exchange":
          performAction("exchange");
          break;
        case "fire":
          if (commands.length > 1) {
            $target.val(commands[1]);
            performAction("fire");
          }
          break;
        case "income":
          performAction("income");
          alterCredibility(selfIndex, 1);
          break;
        case "steal":
          if (commands.length > 1) {
            $target.val(commands[1]);
            performAction("steal");
          }
          break;
        case "stock_options":
        case "stock":
          performAction("stock_options");
          alterCredibility(selfIndex, 2);
      }
    }
    return true;
  };
  performAction = function(action) {
    var targetText, text;
    text = actions[action].text;
    if (actions[action].target) {
      if ($target.val() !== '') {
        targetText = $target.val();
        text += " <strong class=\"text-primary\">" + targetText + "</strong>";
        $target.val('');
        currentAction = false;
      } else {
        currentAction = action;
        $target.trigger('focus');
        return false;
      }
    }
    if (actions[action].credibility) {
      sendCredibilityMessage();
    }
    return sendActionMessage(text);
  };
  $alterAction.on('click', function(event) {
    var $that, action;
    event.preventDefault();
    $that = $(this);
    action = $that.data('action');
    return performAction(action);
  });
  $target.on('keydown', function(event) {
    if (event.keyCode === 13 && currentAction) {
      $("[data-action=" + currentAction + "]").trigger('click');
    }
    return true;
  });
  sendCardMessage = function(position, card) {
    socket.emit('send', {
      username: name,
      message: "<em>changed " + position + " to <strong class=\"text-success\">" + card + "</strong></em>"
    });
    return $('#actionsModal').modal('hide');
  };
  $alterCard.on('click', function(event) {
    var $that, card, cardIndex;
    event.preventDefault();
    $that = $(this);
    cardIndex = $that.data('card-index');
    return card = $that.data('card');
  });
  performCardAction = function(cardIndex, card) {
    if (cardPositions[cardIndex] && cards[card]) {
      socket.emit('game:alterCard', {
        playerIndex: selfIndex,
        cardIndex: cardIndex,
        src: cards[card].src
      });
      return sendCardMessage(cardPositions[cardIndex], cards[card].title);
    }
  };
  socket.emit('game:reset');
});
