extends State

# The enemy attack state:
# The enemy fires an attack at the player. Once the enemy fires 2-4 shots,
# The enemy returns to the prev state

var attackCount = 0
var attackDone = false
var attackQueue = false
export var shotsFired = 3

func enter(host: Enemy):
	attackCount = 0
	attackDone = false
	attackQueue = false
	host.animPlayer.connect("animation_finished", self, "animationDone", [], CONNECT_ONESHOT)
	host.animPlayer.play("attack")

func update(host: Enemy, delta):
	if attackDone:
		return 'previous'
	if attackQueue:
		host.shootStraightShot()
		attackQueue = false

func exit(host):
	$AttackTimer.stop()

func animationDone(anim_name):
	if anim_name == "attack" and attackCount == 0:
		$AttackTimer.start()

func attackTimerTimeOut():
	attackCount += 1
	if attackCount > shotsFired:
		print("exit!")
		attackDone = true #we exit once finishing all fired shots
	else:
		print("Enemy shot ", attackCount, "!")
		attackQueue = true
