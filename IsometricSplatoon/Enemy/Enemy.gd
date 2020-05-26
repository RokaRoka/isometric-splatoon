extends Node2D

#external node refs
onready var inkManager = get_node( "/root/Game/InkManager")

var velocity  = Vector2()
var ground = GroundType.None

#state vars
var states_stack = []
var current_state = null


var health = 175

func _ready():
	$AnimationPlayer.play("float")

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
