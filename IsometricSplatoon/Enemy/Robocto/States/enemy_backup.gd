extends State

# The enemy back up state:
# The enemy runs like a coward away from the player

export (float) var speed = 0
export (float) var maxSpeed = 0

var backUpDone = false

func enter(host: Enemy):
	print("enter enem- RUNAWAY AHHHHH")
	backUpDone = false
	$Timer.start()
	host.animPlayer.play("walk")

func update(host:Enemy, delta):
	if backUpDone:
		return 'previous'
	var awayFromPlayerDir = -host.position.direction_to(host.player.position)
	awayFromPlayerDir = awayFromPlayerDir + awayFromPlayerDir.rotated(-PI/2)
	var finalPosition = host.position + (awayFromPlayerDir.normalized() * host.position.distance_to(host.player.position))
	host.moveTowards(finalPosition, speed, delta)

func _on_Timer_timeout():
	backUpDone = true
