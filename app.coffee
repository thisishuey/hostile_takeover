express = require('express')
app = express()
port = 4839

players = []
turn = 0

app.set('views', "#{__dirname}/tpl")
app.set('view engine', 'html')
app.engine('html', require('ejs').__express)

app.get '/', (request, respond) ->
	respond.render('page')

app.use(express.static("#{__dirname}/public"))
io = require('socket.io').listen(app.listen(port))

io.sockets.on 'connection', (socket) ->
	socket.emit('message', {message: 'Welcome to <strong>Hostile Takeover</strong>!'})

	socket.on 'send', (data = {}) ->
		io.sockets.emit('message', data)

	socket.on 'game:reset', (data = {}) ->
		players = []
		io.sockets.emit('board:update', {players: players})

	socket.on 'game:join', (data = {}) ->
		if data.name
			name = data.name
			player =
				name: name
				cards: ['/images/card_face_down.png', '/images/card_face_down.png']
				credits: 2
			players.push(player)
			io.sockets.emit('board:update', {players: players})

	socket.on 'game:start', (data = {}) ->
		io.sockets.emit('game:start', data)

console.log("Listening on port #{port}")
