name = ''

htmlEntities = (string) ->
	String(string).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;')

pageTitleNotification =
	vars:
		originalTitle: document.title
		interval: null
	on: (notification, intervalSpeed = 1000) ->
		that = this
		that.vars.interval = setInterval ->
			document.title = if that.vars.originalTitle is document.title then notification else that.vars.originalTitle
		, intervalSpeed
		yes
	off: ->
		clearInterval(this.vars.interval)
		document.title = this.vars.originalTitle
		yes

$ ->
	$window = $(window)
	windowFocus = yes
	socket = io.connect(window.location.origin)
	logs = []
	$joinGame = $('#join-game')
	$username = $('#username')
	$joinButton = $('#join')
	$startGame = $('#start-game')
	$startButton = $('#start')
	$playGame = $('#play-game')
	$content = $('#content')
	$name = $('#name')
	$field = $('#field')
	$sendButton = $('#send')

	$window.on 'focus', (event) ->
		windowFocus = yes
		pageTitleNotification.off()
		yes

	$window.on 'blur', (event) ->
		windowFocus = no
		yes

	socket.on 'message', (data) ->
		if data.message
			logs.push(data)
			username = if data.username then data.username else 'Server'
			text = data.message
			$message = $('<div>', {class: 'message'})
			$message.append($('<strong>', {html: "#{username}: "}))
			$message.append(text)
			$content.append($message)
			$content.scrollTop($content.prop('scrollHeight'))
			if data.username and username isnt name and not windowFocus
				pageTitleNotification.off()
				pageTitleNotification.on("#{username} says #{text}", 1500)
		else
			console.log("There is a problem: #{data}")
		yes

	socket.on 'game', (data) ->
		if data.command
			command = data.command
			switch command
				when 'update-board'
					players = data.players
					for index, player of players
						$player = $("#player-#{index}")
						console.log($player)
						$playerPanel = $player.find('.panel')
						$playerTitle = $player.find('.panel-title')
						$playerCards = [$player.find('.card-0'), $player.find('.card-1')]
						$playerCredits = $player.find('.credits')

						$playerPanel.removeClass('panel-default').addClass('panel-primary')
						$playerTitle.html(player.name)
						$playerCards[0].prop('src', player.cards[0])
						$playerCards[1].prop('src', player.cards[1])
						$playerCredits.html("#{player.credits} Credits")
					console.log(players)

	joinGame = ->
		if $username.val() is ''
			alert('Please enter your name!')
		else
			name = htmlEntities($username.val())
			$name.html(name)
			player =
				name: name
				cards: ['/images/card_face_down.png', '/images/card_face_down.png']
				credits: 2
			socket.emit('send', {message: "<em>#{name} joined the game</em>"})
			socket.emit('play', {command: 'join-game', player: player})
			$joinGame.collapse('hide')
			$startGame.collapse('show')
		yes

	$joinButton.on 'click', (event) ->
		joinGame()
		yes

	$username.on 'keydown', (event) ->
		if event.keyCode is 13
			joinGame()
		yes

	startGame = ->
		socket.emit('play', {command: 'start-game'})
		$startGame.collapse('hide')
		$playGame.collapse('show')
		$field.trigger('focus')
		yes

	$startButton.on 'click', (event) ->
		startGame()
		yes

	sendMessage = ->
		if $field.val() is ''
			alert('Please enter a message!')
		else
			text = htmlEntities($field.val())
			socket.emit('send', {username: name, message: text})
			$field.val('')
			$field.trigger('focus')
		yes

	$sendButton.on 'click', (event) ->
		sendMessage()
		yes

	$field.on 'keydown', (event) ->
		if event.keyCode is 13
			sendMessage()
		yes

	$username.trigger('focus')
	socket.emit('play', {command: 'reset-game'})

	return
