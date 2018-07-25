extends KinematicBody2D

signal state_changed

#external node refs
onready var inkManager = get_node( "../InkManager") 

#node refs
onready var animPlayer = get_node( "AnimationPlayer" )
onready var weapon = get_node("Weapon")
onready var hitbox = get_node("CollisionShape2D")
#controller vals
export (bool) var keyboardControl = false
var deadZone  = 0.2


#player vars
var inputDir = Vector2()
var velocity  = Vector2()
var lastAnimDir = "down"
var ground = GroundType.None
var canFire = false

#state vars
var states_stack = []
var current_state = null
onready var states_map = {
	'kid_idle' : $States/Kid_Idle,
	'kid_run' : $States/Kid_Run,
	'squid_idle' : $States/Squid_Idle,
	'squid_swim' : $States/Squid_Swim
}

func _ready():
	states_stack.push_front( $States/Kid_Idle )
	current_state = states_stack[0]
	_change_state('kid_idle')


func _input(event):
	var state_name = current_state.handle_input(self, event)
	if state_name:
		_change_state(state_name)

func _physics_process(delta):
	inputDir = GetDirectionInput()
	lastAnimDir = GetAnimDirection()
	ground = GetGroundType()
	
	var state_name = current_state.update(self, delta)
	if state_name:
		_change_state(state_name)


# STATE FUNCTIONS #
func _change_state(state_name):
	current_state.exit(self)
	
	if state_name == 'previous':
		states_stack.pop_front()
	#do a elif here for states that stack (i.e. like jumping or firing)
	else:
		var new_state = states_map[state_name]
		states_stack[0] = new_state
	
	current_state = states_stack.front()
	if state_name != 'previous':
		current_state.enter(self)
	emit_signal('state_changed', states_stack )


# OTHER FUNCTIONS #
#joystick movement
func GetDirectionInput():
	#swim input
	#if Input.is_action_pressed( "swim" ) and ground == GroundType.MyInk:
	#	swimming = true
	#else:
	#	swimming = false
	
	#movement
	var xAxis = 0
	var yAxis = 0
	
	if Input.get_connected_joypads().size() > 0:
		xAxis = Input.get_joy_axis(0, JOY_AXIS_0)
		yAxis = Input.get_joy_axis(0, JOY_AXIS_1)
		if sqrt(abs(pow(xAxis, 2)) + abs(pow(yAxis, 2))) < deadZone:
			xAxis = 0
			yAxis = 0
	
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


func GetAnimDirection():
	#swim animations
	#if swimming && animPlayer.current_animation != "swim":
	#	animPlayer.play("swim")
	#walk animations
	
	if abs(velocity.x) > abs(velocity.y):
		if velocity.x > 0:
			return 'right'
		else:
			return 'left'
	else:
		if velocity.y > 0:
			return 'down'
		else:
			return 'up'


func GetGroundType():
	
	return inkManager.getGroundTypeAtPosition( global_position )

func CheckForMyInk():
	return ground == GroundType.MyInk

func CheckForTheirInk():
	return ground == GroundType.TheirInk

func HandleVelocity(speed, maxSpeed):
	var newVelocity = velocity
	
	#for x decel
	if inputDir.x == 0:
		#find the direction
		if velocity.x > 0:
			newVelocity.x = max(0, velocity.x - speed)
		elif velocity.x < 0:
			newVelocity.x = min(0, velocity.x + speed)
	#for x accel
	else:
		newVelocity.x += inputDir.x * speed
	
	#for y decel
	if inputDir.y == 0:
		#find the direction
		if velocity.y > 0:
			newVelocity.y = max(0, velocity.y - speed)
		elif velocity.y < 0:
			newVelocity.y = min(0, velocity.y + speed)
	#for x accel
	else:
		newVelocity.y += inputDir.y * speed
	
	#cap the velocity if it reaches the max
	if newVelocity.length_squared() > pow(maxSpeed, 2):
		newVelocity = newVelocity.normalized() * maxSpeed
	
	return newVelocity