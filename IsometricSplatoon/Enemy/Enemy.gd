extends Node2D
class_name Enemy

signal state_changed( states_stack )

var bullet = preload("res://Enemy/enemy_bullet.tscn")
var timedInkSplat = preload("res://Player/Temp/Weapon/TimedSplat.tscn")

#external node refs
onready var navigation = get_node("/root/Game/Navigation2D")
onready var inkManager = get_node( "/root/Game/InkManager")

onready var animPlayer = $AnimationPlayer

export var speed := 80
var ground := GroundType.TheirInk

#enemy behavior vars
var player
var detectionRangeSqd = 512
var playerDetected := false
var attackRangeSqd := 164
var playerInRange := false

#state vars
var states_stack = []
var current_state = null
onready var states_map = {
	'idle': $States/Idle,
	'chase': $States/Chase,
	'attack': $States/Attack,
	'back_up': $States/BackUp,
	'attack2': $States/Attack2
}


var health = 300

func _ready():
	$AnimationPlayer.play("idle")
	player = get_tree().get_nodes_in_group("player")[0]
	
	states_stack.push_front(states_map['idle'])
	current_state = states_stack.front()
	

func _physics_process(delta):
	getPlayerDetection()
	
	var state_name = current_state.update(self, delta)
	if state_name:
		_change_state(state_name)

func getPlayerDetection():
	if position.distance_to(player.position) < detectionRangeSqd:
		#print("dist sqd from player ", position.distance_to(player.position))
		playerDetected = true
		if position.distance_to(player.position) < attackRangeSqd:
			playerInRange = true
		else:
			playerInRange = false
	else:
		playerDetected = false
		playerInRange = false

func moveTowards(var targetPosition, var speed, var delta:float ):
	#var path = navigation.get_simple_path(position, targetPosition)
	animPlayer.play("walk")
	position = position.move_toward(targetPosition, delta * speed)

# STATE FUNCTIONS #
func _change_state(state_name):
	current_state.exit(self)
	
	if state_name == 'previous':
		states_stack.pop_front()
	else:
		var new_state = states_map[state_name]
		states_stack[0] = new_state
	
	current_state = states_stack.front()
	if state_name != 'previous':
		current_state.enter(self)
	emit_signal('state_changed', states_stack )

func _add_state(state_name):
	var new_state = states_map[state_name]
	states_stack.push_front(new_state)
	current_state = states_stack.front()
	current_state.enter(self)
	emit_signal('state_changed', states_stack )

func dirToPlayer():
	return position.direction_to(player.position).normalized()

func shootStraightShot(var shotCount = 1, var maxShotCount = 3):
	var aimDir = dirToPlayer()
	var newBullet = bullet.instance()
	newBullet.setUpBullet( 30, 200, 1, aimDir)
	get_node("/root/Game/Entities").add_child(newBullet)
	newBullet.position = position + aimDir * 5
	
	var newTimedInkSplat = timedInkSplat.instance()
	get_node("/root/Game").add_child(newTimedInkSplat)
	newTimedInkSplat.assignRandomSplat(global_position + (aimDir * (200 * shotCount/maxShotCount)), 1, 1, GroundType.TheirInk)

func internalFailure(var time = 3):
	var newBullet = bullet.instance()
	newBullet.setUpBullet( 80, 20, time, Vector2.DOWN)
	get_node("/root/Game/Entities").add_child(newBullet)
	newBullet.position = global_position + Vector2.UP * 16
	
	var newTimedInkSplat = timedInkSplat.instance()
	get_node("/root/Game").add_child(newTimedInkSplat)
	newTimedInkSplat.assignRandomSplat(global_position, time, 3, GroundType.TheirInk)

func takeDamage(dmgAmount):
	#particle effect!
	$HitParticle.restart()
	$HitParticle.emitting = true
	#sound
#	$AudioStreamPlayer.PlayAudio("hit")
	#damage
	health -= dmgAmount
	if health <= 0:
		$Hitbox.monitoring = false
		$Hitbox.monitorable = false
		queue_free()

func _on_body_entered(body):
	if body.is_in_group("bullet"):
		var bullet = body
		takeDamage(bullet.damageDirect)
