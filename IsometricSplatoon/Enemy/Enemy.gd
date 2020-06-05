extends Node2D
class_name Enemy

#external node refs
onready var navigation = get_node("/root/Game/Navigation2D")
onready var inkManager = get_node( "/root/Game/InkManager")

onready var animPlayer = $AnimationPlayer

var velocity := Vector2()
var ground := GroundType.None

#enemy behavior vars
var detectionRangeSqd = 412
var playerDetected := false

#state vars
var states_stack = []
var current_state = null
var states_map = {
	'idle': $States/Idle,
	'chase': $States/Chase
}


var health = 175

func _ready():
	$AnimationPlayer.play("float")

func _physics_process(delta):
	getDetection()
	
	var state_name = current_state.update(self, delta)
	if state_name:
		_change_state(state_name)

func getDetection():
	var player = get_tree().get_nodes_in_group("player").front()
	if position.distance_squared_to(player.position) < detectionRangeSqd:
		playerDetected = true
	else:
		playerDetected = false

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

func takeDamage(dmgAmount):
	#particle effect!
#	$HitParticle.restart()
#	$HitParticle.emitting = true
#	
	#sound
#	$AudioStreamPlayer.PlayAudio("hit")
	
	#damage
	health -= dmgAmount
	if health <= 0:
		$Hitbox.monitoring = false
		$Hitbox.monitorable = false
		queue_free()
#		$AnimationPlayer.play("pop")
#		emit_signal("popped")

func _on_body_entered(body):
	if body.is_in_group("bullet"):
		var bullet = body
		takeDamage(bullet.damageDirect)
