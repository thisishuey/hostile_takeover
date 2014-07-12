// Generated by CoffeeScript 1.7.1
var app, express, io, players, port, turn;

express = require('express');

app = express();

port = 4839;

players = [];

turn = 0;

app.set('views', "" + __dirname + "/tpl");

app.set('view engine', 'html');

app.engine('html', require('ejs').__express);

app.get('/', function(request, respond) {
  return respond.render('page');
});

app.use(express["static"]("" + __dirname + "/public"));

io = require('socket.io').listen(app.listen(port));

io.sockets.on('connection', function(socket) {
  socket.emit('message', {
    message: 'Welcome to <strong>Hostile Takeover</strong>!'
  });
  socket.on('send', function(data) {
    if (data == null) {
      data = {};
    }
    return io.sockets.emit('message', data);
  });
  socket.on('game:reset', function(data) {
    if (data == null) {
      data = {};
    }
    players = [];
    return io.sockets.emit('board:update', {
      players: players
    });
  });
  socket.on('game:join', function(data) {
    var name, player;
    if (data == null) {
      data = {};
    }
    if (data.name) {
      name = data.name;
      player = {
        name: name,
        cards: ['/images/card_face_down.png', '/images/card_face_down.png'],
        credits: 2
      };
      players.push(player);
      return io.sockets.emit('board:update', {
        players: players
      });
    }
  });
  return socket.on('game:start', function(data) {
    if (data == null) {
      data = {};
    }
    return io.sockets.emit('game:start', data);
  });
});

console.log("Listening on port " + port);
