name = ''
selfIndex = -1
currentAction = off

actions =
	income:
		title: 'Income'
		text: 'takes <strong class="text-success">Income</strong>'
	stock_options:
		title: 'Stock Options'
		text: 'takes <strong class="text-success">Stock Options</strong>'
	downsize:
		title: 'Downsize'
		target: yes
		text: 'performs <strong class="text-success">Downsize</strong> on'
	dividends:
		title: 'Dividends'
		text: 'takes <strong class="text-success">Dividends</strong>'
	block_stock_options:
		title: 'Block Stock Options'
		target: yes
		text: 'blocks <strong class="text-danger">Stock Options</strong> on'
	steal:
		title: 'Steal'
		target: yes
		text: '<strong class="text-success">Steals</strong> from'
	block_steal_one_upper:
		title: 'Block Steal (One-Upper)'
		target: yes
		text: '<strong class="text-danger">Blocks Steal (One-Upper)</strong> from'
	exchange:
		title: 'Exchange'
		text: '<strong class="text-success">Exchanges</strong> cards'
	block_steal_vp:
		title: 'Block Steal (VP)'
		target: yes
		text: '<strong class="text-danger">Blocks Steal (VP)</strong> from'
	fire:
		title: 'Fire'
		target: yes
		text: '<strong class="text-success">Fires</strong>'
	block_fire:
		title: 'Block Fire'
		target: yes
		text: '<strong class="text-danger">Blocks Fire</strong> from'
	report_credibility:
		title: 'Report Credibility'
		credibility: yes
		text: 'now has'
	call_bluff:
		title: 'Call Bluff'
		target: yes
		text: '<strong class="text-success">Calls Bluff</strong> on'
	bluffed_cfo:
		title: 'Bluffed CFO'
		text: '<strong class="text-danger">Bluffed CFO</strong>'
	bluffed_one_upper:
		title: 'Bluffed One-Upper'
		text: '<strong class="text-danger">Bluffed One-Upper</strong>'
	bluffed_vp:
		title: 'Bluffed VP'
		text: '<strong class="text-danger">Bluffed VP</strong>'
	bluffed_manager:
		title: 'Bluffed Manager'
		text: '<strong class="text-danger">Bluffed Manager</strong>'
	bluffed_hr:
		title: 'Bluffed HR'
		text: '<strong class="text-danger">Bluffed HR</strong>'
	resign:
		title: 'Resign'
		text: 'has <strong class="text-danger">Resigned</strong>'
	hostile_takeover:
		title: 'Hostile Takeover'
		text: '<strong class="text-success">has WON HOSTILE TAKEOVER!!!</strong>'

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
	socket = io.connect(location.origin)
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
	$alterAction = $('.alter-action')
	$target = $('#target')
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

					if selfIndex < 0 and player.name is name
						selfIndex = playerIndex

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

	sendActionMessage = (text, target = false) ->
		socket.emit('send', {username: name, message: "<em>#{text}</em>"})
		$('#actionsModal').modal('hide')

	$alterAction.on 'click', (event) ->
		event.preventDefault()
		$that = $(this)
		action = $that.data('action')
		text = actions[action].text
		if actions[action].target
			if $target.val() isnt ''
				targetText = $target.val()
				text += " <strong class=\"text-primary\">#{targetText}</strong>"
				$target.val('')
				currentAction = off
			else
				currentAction = action
				$target.trigger('focus')
				return no
		if actions[action].credibility
			credibilityText = $("#player-#{selfIndex} .credibility").text()
			text += " <strong class=\"text-success\">#{credibilityText}</strong>"
		sendActionMessage(text)

	$target.on 'keydown', (event) ->
		if event.keyCode is 13 and currentAction
			$("[data-action=#{currentAction}]").trigger('click')
		yes

	sendCardMessage = (position, card) ->
		socket.emit('send', {username: name, message: "<em>changed #{position} to <strong class=\"text-success\">#{card}</strong></em>"})
		$('#actionsModal').modal('hide')

	$alterCard.on 'click', (event) ->
		event.preventDefault()
		$that = $(this)
		cardIndex = $that.data('card-index')
		card = $that.data('card')
		socket.emit('game:alterCard', {playerIndex: selfIndex, cardIndex: cardIndex, src: cards[card].src})
		sendCardMessage(cardPositions[cardIndex], cards[card].title)

	socket.emit('game:reset')

	return
