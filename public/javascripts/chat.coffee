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

	socket.on 'message', (data = {}) ->
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

	socket.on 'game:start', (data = {}) ->
		$emptyPanels = $('.panel-empty')
		$emptyPanels.css('opacity', 0.25)
		$startGame.collapse('hide')
		$playGame.collapse('show')
		$field.trigger('focus')
		yes

	socket.on 'board:update', (data = {}) ->
		if data.players
			players = data.players
			activeSelector = data.activeSelector or off

			for playerIndex, player of players
				$player = $("#player-#{playerIndex}")
				$playerPanel = $player.find('.panel')
				$playerTitle = $player.find('.panel-title')
				$playerCards = [$player.find('.card-0'), $player.find('.card-1')]
				$playerCredibility = $player.find('.credibility')

				$playerPanel.prop('class', 'panel panel-default')
				$playerTitle.html(player.name)
				for cardIndex, card of player.cards
					$playerCards[cardIndex].prop('src', card)
				$playerCredibility.html("#{player.credibility} Credibility")

			if activeSelector isnt off
				$playerPanel = $("#{activeSelector} .panel")
				$playerPanel.prop('class', 'panel panel-primary')

			if players.length < 2
				$startButton.prop('disabled', yes)
			else
				$startButton.prop('disabled', no)

	joinGame = ->
		if $username.val() is ''
			alert('Please enter your name!')
		else
			name = htmlEntities($username.val())
			$name.html(name)
			socket.emit('send', {message: "<em>#{name} joined the game</em>"})
			socket.emit('game:join', {name: name})
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

	$startButton.on 'click', (event) ->
		socket.emit('game:start')
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
	socket.emit('game:reset')

	return
