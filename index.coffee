express = require('express')
app = express()
port = 4839

app.set('views', "#{__dirname}/tpl")
app.set('view engine', 'html')
app.engine('html', require('ejs').__express)

app.get '/', (request, respond) ->
	respond.render('page')

app.use(express.static("#{__dirname}/public"))
io = require('socket.io').listen(app.listen(port))

io.sockets.on 'connection', (socket) ->
	socket.emit('message', {message: 'Welcome to <strong>Hostile Takeover</strong>!'})
	socket.on 'send', (data) ->
		io.sockets.emit('message', data)
	socket.on 'play', (data) ->
		io.sockets.emit('game', data)

console.log("Listening on port #{port}")
