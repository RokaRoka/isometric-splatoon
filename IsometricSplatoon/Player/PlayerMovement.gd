extends KinematicBody2D

#exports
export (int) var speed = 10

#controller vals
var deadZone  = 0.2
var velocity  = Vector2()
var playerNum = 0

#node refs
onready var animPlayer = get_node( "AnimationPlayer" )

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	#Input.connect("joy_connect_changed", self, "joy_con_changed")	
	pass

func joy_con_changed(deviceid, isConnected):
	if isConnected:
		print("Joystick " + str(deviceid) + " connected")
		if Input.is_joy_known(playerNum):
			print("Recognized controller")
			print(Input.get_joy_name(playerNum) + " Device found")
	else:
		print("Controller D/C")


# Called every frame. Delta is time since last frame.
# Update game logic here.
func _physics_process(delta):
	ControllerMovement()
	move_and_collide(velocity)


#joystick movement
func ControllerMovement(): 
	velocity = Vector2()
	if Input.get_connected_joypads().size() > 0:
		var xAxis = Input.get_joy_axis(playerNum, JOY_AXIS_0)
		var yAxis = Input.get_joy_axis(playerNum, JOY_AXIS_1)
		if abs(xAxis) > deadZone:
			if xAxis < 0:
				velocity.x = xAxis
				#animPlayer.play( "move_left" )
			if xAxis > 0:
				velocity.x = xAxis
				#animPlayer.play( "move_right" )
		if abs(yAxis) > deadZone:
			if yAxis < 0:
				velocity.y = yAxis
				if not animPlayer.current_animation == "move_up":
					animPlayer.play( "move_up" )
			if yAxis > 0:
				velocity.y = yAxis
				if not animPlayer.current_animation == "move_down":
					animPlayer.play( "move_down" )
	else:
		animPlayer.stop()

	velocity = velocity.normalized() * speed