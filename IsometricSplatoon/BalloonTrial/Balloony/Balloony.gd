extends RigidBody2D

signal popped

var health = 75

func _ready():
	$AnimationPlayer.play("float")

func takeDamage(dmgAmount):
	#particle effect!
	$HitParticle.restart()
	$HitParticle.emitting = true
	#sound
	$AudioStreamPlayer.PlayAudio("hit")
	#damage
	health -= dmgAmount
	if health <= 0:
		$AnimationPlayer.play("pop")
		emit_signal("popped")

func _on_Balloony_body_entered(body):
	#print("body name is "+body.name)
	if body.is_in_group("bullet"):
		var bullet = body
		takeDamage(bullet.damageDirect)
