extends State

# The enemy idle state:
# The enemy has a detection radius to determine when to chase the player
# If the enemy's attention is ON the player, it'll track and try to position to attack 


func enter(host: Enemy):
	host.animPlayer.play("idle")

#func exit(host):
#	return

#func handle_input(host, event):
#	return

func update(host, delta):
	if host.playerDetected:
		return 'chase'
