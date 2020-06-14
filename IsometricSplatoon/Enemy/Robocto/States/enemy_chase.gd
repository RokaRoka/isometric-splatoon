extends State

# The enemy chase state:
# The enemy runs like an idiot at the player

export (float) var speed = 0
export (float) var maxSpeed = 0

func enter(host: Enemy):
	print("enter enemy chase")
	host.animPlayer.play("walk")

func update(host:Enemy, delta):
	#if near a player, pop up an attack state
	if host.playerInRange:
		var randNum = randi() % 3
		if randNum > 1:
			host._add_state('attack')
		else:
			host._add_state('attack2')
	else:
		host.moveTowards(host.player.position, speed, delta)
	
	if !host.playerDetected:
		return 'idle'
