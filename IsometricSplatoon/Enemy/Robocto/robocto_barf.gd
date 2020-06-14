extends State

# The enemy barf state:
# The enemy fires an attack at the player. Once the enemy fires 2-4 shots,
# The enemy returns to the prev state

var attackDone = false
var attackQueue = false

func enter(host: Enemy):
	attackDone = false
	attackQueue = false
	host.animPlayer.connect("animation_finished", self, "animationDone", [], CONNECT_ONESHOT)
	host.animPlayer.play("barf")

func update(host: Enemy, delta):
	if attackDone:
		return 'back_up'
	if attackQueue:
		host.internalFailure(1)
		attackQueue = false

func exit(host):
	$FinishTimer.stop()

func animationDone(anim_name):
	if anim_name == "barf":
		attackQueue = true
		$FinishTimer.start()

func attackTimerTimeOut():
	attackDone = true #we exit once finishing all fired shots
