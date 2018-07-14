extends KinematicBody2D

#exports
export (int) var walkSpeed = 0
export (int) var swimSpeed = 0

export (float) var walkMaxSpeed = 0
export (float) var swimMaxSpeed = 0

#controller vals
export (bool) var keyboardControl = false
var deadZone  = 0.15

#movement
var velocity  = Vector2()
var playerNum = 0

#transition values
var swimming = false

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
	var dir = GetInput()
	HandleVelocity(dir)
	HandleAnimation()
	move_and_collide(velocity * delta)

#joystick movement
func GetInput():
	
	#swim input
	if Input.is_action_pressed( "swim" ):
		swimming = true
	else:
		swimming = false
	
	#movement
	var xAxis = 0
	var yAxis = 0
	
	if Input.get_connected_joypads().size() > 0:
		xAxis = Input.get_joy_axis(playerNum, JOY_AXIS_0)
		yAxis = Input.get_joy_axis(playerNum, JOY_AXIS_1)
	
	if keyboardControl:
		if Input.is_action_pressed("move_down"):
			yAxis = 1
		if Input.is_action_pressed("move_up"):
			yAxis = -1
		if Input.is_action_pressed("move_right"):
			xAxis = 1
		if Input.is_action_pressed("move_left"):
			xAxis = -1
	
	var axisTotal = Vector2(xAxis, yAxis)
	if axisTotal.length() > 1 or axisTotal.length() < -1:
		axisTotal = axisTotal.normalized()
	
	return axisTotal


func HandleVelocity(dir):
	#default movement vars
	var speed = walkSpeed
	var maxSpeed = walkMaxSpeed
	
	var deceleration = Vector2()
	var acceleration = Vector2()
	var newVelocity = velocity
	
	#set speed and max speed based on form
	if swimming:
		speed = swimSpeed
		maxSpeed = swimMaxSpeed
	
	#for x decel
	if dir.x == 0:
		#find the direction
		if velocity.x > 0:
			newVelocity.x = max(0, velocity.x - speed)
		elif velocity.x < 0:
			newVelocity.x = min(0, velocity.x + speed)
	#for x accel
	else:
		newVelocity.x += dir.x * speed
	
	#for y decel
	if dir.y == 0:
		pass#find the direction
		if velocity.y > 0:
			newVelocity.y = max(0, velocity.y - speed)
		elif velocity.y < 0:
			newVelocity.y = min(0, velocity.y + speed)
	#for x accel
	else:
		newVelocity.y += dir.y * speed
	
	#cap the velocity if it reaches the max
	if newVelocity.length_squared() > pow(maxSpeed, 2):
		velocity = newVelocity.normalized() * maxSpeed
	else:
		velocity = newVelocity


func HandleAnimation():
	#swim animations
	if swimming && animPlayer.current_animation != "swim":
		animPlayer.play("swim")
	#walk animations
	elif not swimming:
		if abs(velocity.x) > abs(velocity.y):
			if velocity.x > 0:
				if animPlayer.current_animation != "move_right":
					animPlayer.play( "move_right" )
			else:
				if animPlayer.current_animation != "move_left":
					animPlayer.play( "move_left" )
		else:
			if velocity.y > 0:
				if animPlayer.current_animation != "move_down":
					animPlayer.play( "move_down" )
			else:
				if animPlayer.current_animation != "move_up":
					animPlayer.play( "move_up" )
		
		if velocity.length_squared() < 0.05:
			animPlayer.stop()