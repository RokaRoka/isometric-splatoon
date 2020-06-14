extends RigidBody2D

var speed = 0
var t = 0.0
var lifeTime = 0
var dir = Vector2()

var damageDirect = 0
var damage = 0

func setUpBullet(var dmg, var spd, var lifetime, var direction, var damageDirect=0):
	damage = dmg
	speed = spd
	lifeTime = lifetime
	dir = direction
	rotation = atan2(dir.y, dir.x)
	self.damageDirect = damageDirect

func _physics_process(delta):
	linear_velocity = dir * speed
	t += delta
	if t >= lifeTime:
		#print('I am a bullet and I am dead!!! t is: '+String(t)+' lifetime: '+String(lifeTime))
		InkManager.inkSplat(InkManager.GroundType.THEIR_INK, global_position, 2)
		queue_free()

func _on_Bullet_body_entered(body:PhysicsBody2D):
	if body.is_in_group("player"):
		print("Ow! I took damage!")
	queue_free()
