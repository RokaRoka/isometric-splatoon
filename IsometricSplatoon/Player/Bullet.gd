extends RigidBody2D

var speed = 0
var t = 0.0
var lifeTime = 0
var dir = Vector2()

var damageDirect = 0
var damage = 0

func _physics_process(delta):
	linear_velocity = dir * speed
	t += delta
	if t >= lifeTime:
		#print('I am a bullet and I am dead!!! t is: '+String(t)+' lifetime: '+String(lifeTime))
		InkManager.inkSplat(InkManager.GroundType.MY_INK, global_position, 2)
		queue_free()



func _on_Bullet_body_entered(body):
	queue_free()
