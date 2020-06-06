extends State

# The enemy chase state:
# The enemy runs like an idiot at the player

export (float) var speed = 0
export (float) var maxSpeed = 0

func enter(host: Enemy):
	print("enter enemy chase")
	host.animPlayer.play("walk")

#func exit(host):
#	return

#func handle_input(host, event):
#	return

func update(host:Enemy, delta):
	#if near a player, pop up an attack state
	if host.playerInRange:
		host._add_state('attack')
	else:
		host.moveTowards(host.player.position, speed, delta)
	
	if !host.playerDetected:
		return 'idle'
