extends State

# The enemy chase state:
# The enemy runs like an idiot at the player

func enter(host: Enemy):
	host.animPlayer.play("walk")

#func exit(host):
#	return

#func handle_input(host, event):
#	return

func update(host:Enemy, delta):
	#use host.navigation to get and follow a path
	
	if !host.playerDetected:
		return 'idle'
