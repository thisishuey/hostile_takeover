# Position		Counteraction			Action			Description
# ========		=============			======			===========
# -				-						Income			Gain 1 Credibility
# -				-						Stock Options	Gain 2 Credibility
# -				-						Downsize		Pay 7 Credibility and target Player loses 1 Influence
# CFO			Block Stock Options		Dividends		Gain 3 Credibility
# One-Upper		Block Steal				Steal			Take 2 Credibility from target Player
# VP			Block Steal				Exchange		Exchange Positions with Corporate Deck
# Manager		-						Fire			Pay 3 Credibility and target Player loses 1 Influence
# HR			Block Fire				-				-

# Duke (Tax) -> CFO (Dividends)
# Captain (Steal) -> One-Upper (Steal)
# Ambassador (Exchange) -> VP (Exchange)
# Assassin (Assassinate) -> Manager (Fire)
# Contessa (Block Assassination) -> HR (Block Firing)

alterCredibility = (playerIndex, amount) ->
	io.connect(window.location.origin).emit("game:alterCredibility", {playerIndex: playerIndex, amount: amount})
	yes

# increaseCredibility = (playerIndex, amount) ->
# 	io.connect(window.location.origin).emit("game:alterCredibility", {playerIndex: playerIndex, amount: amount})
# 	yes

# decreaseCredibility = (playerIndex, amount) ->
# 	io.connect(window.location.origin).emit("game:alterCredibility", {playerIndex: playerIndex, amount: amount * -1})
# 	yes

income = (playerIndex) ->
	alterCredibility(playerIndex, -1)
	yes

stockOptions = ->
	yes

downsize = ->
	yes
