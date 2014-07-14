name = ''
selfIndex = -1

cardPositions = ['first card', 'second card']
cards =
	face_down:
		title: 'Face Down'
		src: '/images/card_face_down.png'
	cfo:
		title: 'CFO'
		src: '/images/card_cfo.png'
	one_upper:
		title: 'One-Upper'
		src: '/images/card_one_upper.png'
	vp:
		title: 'VP'
		src: '/images/card_vp.png'
	manager:
		title: 'Manager'
		src: '/images/card_manager.png'
	hr:
		title: 'HR'
		src: '/images/card_hr.png'
	blank:
		title: 'Blank'
		src: '/images/card_blank.png'

htmlEntities = (string) ->
	String(string).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;')

stripTags = (string) ->
	String(string).replace(/(<([^>]+)>)/ig,"")

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
	$gainCredButton = $('#gainCredibility')
	$loseCredButton = $('#loseCredibility')
	$alterCard = $('.alter-card')

	$window.on 'focus', (event) ->
		windowFocus = yes
		pageTitleNotification.off()
		yes

	$window.on 'blur', (event) ->
		windowFocus = no
		yes

	$gainCredButton.on 'click', (event) ->
		increaseCredibility(selfIndex, 1)
		yes

	$loseCredButton.on 'click', (event) ->
		decreaseCredibility(selfIndex, 1)
		yes

	socket.on 'message', (data = {}) ->
		if data.message
			logs.push(data)
			username = if data.username then data.username else 'Server'
			text = data.message
			$message = $('<div>', {class: 'message'})
			$message.append($('<strong>', {html: "#{username}: ", class: 'text-primary'}))
			$message.append(text)
			$content.append($message)
			$content.scrollTop($content.prop('scrollHeight'))
			if data.username and username isnt name and not windowFocus
				pageTitleNotification.off()
				pageTitleNotification.on("#{username} says #{stripTags(text)}", 1500)
		else
			console.log("There is a problem: #{data}")
		yes

	socket.on 'game:start', (data = {}) ->
		$emptyPanels = $('.panel-empty')
		$emptyPanels.css('opacity', 0.25)
		$joinGame.collapse('hide')
		$startGame.collapse('hide')
		$playGame.collapse('show')
		$field.trigger('focus')
		yes

	socket.on 'board:update', (data = {}) ->
		if data.players
			players = data.players

			if players.length
				for playerIndex, player of players
					if selfIndex < 0 and player.name is name then selfIndex = playerIndex
					$player = $("#player-#{playerIndex}")
					$playerPanel = $player.find('.panel')
					$playerTitle = $player.find('.panel-title')
					$playerCards = [$player.find('.card-0'), $player.find('.card-1')]
					$playerCredibility = $player.find('.credibility')

					if player.active
						$playerPanel.prop('class', 'panel panel-primary')
					else
						$playerPanel.prop('class', 'panel panel-default')

					# Temporary hack until turn functionality is added
					$playerPanel.prop('class', 'panel panel-primary')

					$playerTitle.html(player.name)
					for cardIndex, card of player.cards
						$playerCards[cardIndex].prop('src', card)
					$playerCredibility.html("#{player.credibility} Credibility")

				if players.length < 2
					$startButton.prop('disabled', yes)
				else
					$startButton.prop('disabled', no)

			else
				for playerIndex in [0..5]
					$player = $("#player-#{playerIndex}")
					$playerPanel = $player.find('.panel')
					$playerTitle = $player.find('.panel-title')
					$playerCards = [$player.find('.card-0'), $player.find('.card-1')]
					$playerCredibility = $player.find('.credibility')

					$playerPanel.prop('class', 'panel panel-empty hidden-xs')
					$playerTitle.html("Player #{playerIndex + 1}")
					for cardIndex in [0..1]
						$playerCards[cardIndex].prop('src', '/images/card_blank.png')
					$playerCredibility.html('0 Credibility')

				$startButton.prop('disabled', yes)

				$emptyPanels = $('.panel-empty')
				$emptyPanels.css('opacity', 1.0)
				if not $joinGame.hasClass('in')
					$joinGame.collapse('show')
				if $startGame.hasClass('in')
					$startGame.collapse('hide')
				if $playGame.hasClass('in')
					$playGame.collapse('hide')
				$username.trigger('focus')

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

	sendCardMessage = (position, card) ->
		socket.emit('send', {username: name, message: "<em>changed #{position} to <strong class=\"text-success\">#{card}</strong></em>"})
		$('#actionsModal').modal('hide')

	$alterCard.on 'click', (event) ->
		event.preventDefault()
		$that = $(this)
		card = $that.data('card')
		cardIndex = $that.data('card-index')
		socket.emit('game:alterCard', {playerIndex: selfIndex, cardIndex: cardIndex, src: cards[card].src})
		sendCardMessage(cardPositions[cardIndex], cards[card].title)

	socket.emit('game:reset')

	return
