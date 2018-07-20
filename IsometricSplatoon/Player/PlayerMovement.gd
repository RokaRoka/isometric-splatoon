extends KinematicBody2D

#exports
export (int) var walkSpeed = 0
export (int) var swimSpeed = 0
export (int) var squidSpeed = 0

export (float) var walkMaxSpeed = 0
export (float) var swimMaxSpeed = 0
export (float) var squidMaxSpeed = 0

#controller vals
export (bool) var keyboardControl = false
var deadZone  = 0.15

#movement
var inputDir = Vector2()
var velocity  = Vector2()
var lastAnimDir = "move_down"
var playerNum = 0

#transition values
var ground = GroundType.None
var swimming = false

#external node refs
onready var inkManager = get_node( "../InkManager") 

#node refs
onready var animPlayer = get_node( "AnimationPlayer" )

signal state_changed

var current_state = null
onready var states_map = {
	'kid_movement' : $States/Kid_Movement,
	'squid_movement' : $States/Squid_Movement
}

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	#Input.connect("joy_connect_changed", self, "joy_con_changed")	
	pass


func _change_state(state_name):
	current_state.exit(self)
	
	#blah blah blah
	current_state = states_map[state_name]
	
	emit_signal('state_changed', current_state )

"""
func joy_con_changed(deviceid, isConnected):
	if isConnected:
		print("Joystick " + str(deviceid) + " connected")
		if Input.is_joy_known(playerNum):
			print("Recognized controller")
			print(Input.get_joy_name(playerNum) + " Device found")
	else:
		print("Controller D/C")
"""

# Called every frame. Delta is time since last frame.
# Update game logic here.
func _physics_process(delta):
	CheckAndHandleGround()
	var dir = GetInput()
	HandleVelocity(dir)
	HandleAnimation()
	move_and_collide(velocity * delta)

func CheckAndHandleGround():
	#first, check position
	var groundType = inkManager.getGroundTypeAtPosition( position )
	if groundType != ground:
		print("New ground! Is "+String(groundType))
	ground = groundType


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
				lastAnimDir = "move_right"
			else:
				lastAnimDir = "move_left"
		else:
			if velocity.y > 0:
				lastAnimDir = "move_down"
			else:
				lastAnimDir = "move_up"
		
		if animPlayer.current_animation != lastAnimDir:
			animPlayer.play( lastAnimDir )
		if velocity.length_squared() < 0.05:
			animPlayer.stop()