extends RigidBody2D

var speed = 0
var t = 0.0
var lifeTime = 0
var dir = Vector2()

#func _ready():
	#print("I am a bullet! I am at pos:" + String(position))

func _physics_process(delta):
	linear_velocity = dir * speed
	t += delta
	if t >= lifeTime:
		#print('I am a bullet and I am dead!!! t is: '+String(t)+' lifetime: '+String(lifeTime))
		get_node( "/root/Game/InkManager" ).inkSplat(GroundType.MyInk, global_position, 2)
		queue_free()