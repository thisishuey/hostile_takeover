name = '&lt;anon&gt;'

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

	joinGame = ->
		if $username.val() is ''
			alert('Please enter your name!')
		else
			name = htmlEntities($username.val())
			$name.html(name)
			socket.emit('send', {message: "<em>#{name} just joined the chat</em>"})
			$joinGame.collapse('hide')
			$playGame.collapse('show')
			$field.trigger('focus')
		yes

	$joinButton.on 'click', (event) ->
		joinGame()
		yes

	$username.on 'keydown', (event) ->
		if event.keyCode is 13
			joinGame()
		yes

	sendMessage = ->
		if $field.val() is ''
			alert('Please enter a message!')
		else
			text = htmlEntities($field.val())
			socket.emit('send', {username: name, message: text})
			$field.val('')
		yes

	$sendButton.on 'click', (event) ->
		sendMessage()
		yes

	$field.on 'keydown', (event) ->
		if event.keyCode is 13
			sendMessage()
		yes

	$username.trigger('focus')

	return
