extends KinematicBody2D

#external node refs
onready var inkManager = get_node( "/root/Game/InkManager")

var velocity  = Vector2()
var ground = GroundType.None

#ink stuff
var inkTank = 1.0
var inkRecovering = false
var inkRecoverRestartCount = 0 #this one counts
var inkRecoverRestartTime = 1.5 #this is the num that has to be reached to restart

#state vars
var states_stack = []
var current_state = null


var health = 75

func _ready():
	$AnimationPlayer.play("float")

func takeDamage(dmgAmount):
#	#particle effect!
#	$HitParticle.restart()
#	$HitParticle.emitting = true
#	#sound
#	$AudioStreamPlayer.PlayAudio("hit")
	#damage
	health -= dmgAmount
#	if health <= 0:
#		$AnimationPlayer.play("pop")
#		emit_signal("popped")

func _on_Balloony_body_entered(body):
	#print("body name is "+body.name)
	if body.is_in_group("bullet"):
		var bullet = body
		takeDamage(bullet.damageDirect)
