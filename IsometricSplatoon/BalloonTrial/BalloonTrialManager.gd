extends Node

signal balloon_score_update(newScore)
signal balloons_reset
signal timer_update(newTime)

#refs
onready var balloonSpawnPos = get_node("/root/Game/BalloonSpawnPositions")
var balloony = preload("res://BalloonTrial/Balloony/Balloony.tscn")

#overall vars
var started = false
var complete = false

#balloon vars
var balloonSlots = []
var balloonScore = 0
var balloonMax = 15

#completion timer
var completion_t = 0.0
var completion_cap = 9999.0


func _ready():
	balloonSlots = balloonSpawnPos.get_children()
	StartTrial() #temporarily in ready

func _process(delta):
	if started and not complete:
		TimerTick(delta)

func StartTrial():
	started = true
	$SpawnTimer.start()

func TimerTick(delta):
	if completion_t < completion_cap:
		completion_t += delta
		emit_signal( "timer_update", completion_t )

func SpawnBalloon(position):
	print("Balloon spawned at: "+str(position))
	
	var newBalloony = balloony.instance()
	get_node("/root/Game").add_child(newBalloony)
	newBalloony.position = position
	newBalloony.connect( "popped", self, "_on_Balloon_popped")

func _on_Balloon_popped():
	if balloonScore < balloonMax:
		balloonScore += 1
		emit_signal("balloon_score_update", balloonScore)
		#When balloon score hits a certain point, increase difficulty(?)
		if balloonScore == 5:
			$SpawnTimer.wait_time /= 2
		if balloonScore == 10:
			$SpawnTimer.wait_time /= 2
	
	if balloonScore >= balloonMax:
		complete = true
		$SpawnTimer.stop()

func _on_SpawnTimer_timeout():
	var r_num = randi() % balloonSlots.size()
	SpawnBalloon(balloonSlots[r_num].global_position)
