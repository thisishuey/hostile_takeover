express = require('express')
app = express()
port = 4839

players = []
activeID = 0
cardPositions = ['first card', 'second card']
cards =
	blank:
		title: 'Blank'
		source: '/images/card_blank.png'
	face_down:
		title: 'Face Down'
		source: '/images/card_face_down.png'
	cfo:
		title: 'CFO'
		source: '/images/card_cfo.png'
	one_upper:
		title: 'One-Upper'
		source: '/images/card_one_upper.png'
	vp:
		title: 'VP'
		source: '/images/card_vp.png'
	manager:
		title: 'Manager'
		source: '/images/card_manager.png'
	hr:
		title: 'HR'
		source: '/images/card_hr.png'

app.set('views', "#{__dirname}/tpl")
app.set('view engine', 'html')
app.engine('html', require('ejs').__express)

app.get '/', (request, respond) ->
	respond.render('page')

app.use(express.static("#{__dirname}/public"))
io = require('socket.io').listen(app.listen(port))

io.sockets.on 'connection', (socket) ->
	socket.emit('message', {message: 'Welcome to <strong class=\"text-primary\">Hostile Takeover</strong>!'})

	socket.on 'send', (data = {}) ->
		io.sockets.emit('message', data)

	socket.on 'game:reset', (data = {}) ->
		players = []
		updateBoard()

	socket.on 'game:join', (data = {}) ->
		if data.name
			name = data.name
			player =
				name: name
				cards: [cards.face_down.source, cards.face_down.source]
				credibility: 2
				active: players.length < 1
			players.push(player)
			updateBoard()

	socket.on 'game:start', (data = {}) ->
		io.sockets.emit('game:start', data)
		updateBoard()

	socket.on 'game:alterCard', (data = {}) ->
		if data.playerIndex isnt null and data.cardIndex isnt null
			player = players[data.playerIndex]
			card = cards[data.cardIndex]
			cardPosition = 0
			if data.cardPosition isnt no
				console.log(data.cardPosition)
				cardPosition = data.cardPosition
			else if player.cards[cardPosition] isnt cards.face_down.source
				cardPosition = 1
			player.cards[cardPosition] = card.source
			io.sockets.emit('message', {username: player.name, message: "<em>changed #{cardPositions[cardPosition]} to <strong class=\"text-success\">#{card.title}</strong></em>"})
			updateBoard()

	socket.on 'game:action', (data = {}) ->
		if data.playerIndex isnt null
			updateBoard()

	socket.on 'game:counterAction', (data = {}) ->
		if data.playerIndex isnt null
			updateBoard()

	socket.on 'game:alterCredibility', (data = {}) ->
		if data.playerIndex isnt null and data.amount isnt null
			if data.amount >= 0 or data.amount * -1 <= players[data.playerIndex].credibility
				players[data.playerIndex].credibility += data.amount
			updateBoard()
		yes

	yes

updateBoard = () ->
	io.sockets.emit('board:update', {players: players})
	yes

console.log("Listening on port #{port}")
