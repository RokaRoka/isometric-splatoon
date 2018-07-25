extends Node2D

onready var player = get_node( ".." )
var bullet = preload("res://Player/Temp/Weapon/bullet.tscn")


#default firing data
var bufferedAimInput = Vector2()
var aimDir = Vector2()
var firing = false
var fireCooldown = 0.0
var bulletArray = []


#weapon data
var weaponRange = 256.0 #pixels?? I think?
var weaponBulletSpeed = 432.0 #pixel per second(?)
var weaponFireRate = 8 #shots per second


#paint data
var minPaintDist = 48
var maxPaintDist = 240
var paintDistances = []
var paintStack = []

func _ready():
	fireCooldown = 1.0/weaponFireRate
	refillStack()

func _input(event):
	#aim the mouse with keyboard debugging
	if event is InputEventMouseMotion and player.keyboardControl:
		if event.relative.length() > 2: 
			bufferedAimInput = (event.position - player.position).normalized()
	elif event is InputEventJoypadMotion and event.is_action("aim"):
		if event.axis == JOY_AXIS_2: #and abs(event.axis_value) > player.deadZone:
			bufferedAimInput.x = event.axis_value
		elif event.axis == JOY_AXIS_3: #and abs(event.axis_value) > player.deadZone:
			bufferedAimInput.y = event.axis_value
	#fire the gun
	if Input.is_action_pressed("fire") and player.canFire:
		startFiring()
	else:
		endFiring()

func _physics_process(delta):
	updateAim()
	
	if fireCooldown <= 1.0/weaponFireRate:
		fireCooldown += delta
	elif firing:
		fireBullet()
		fireCooldown -= 1.0/weaponFireRate

func startFiring():
	firing = true

func endFiring():
	firing = false

func updateAim():
	if bufferedAimInput.length() > player.deadZone:
		#print(String(bufferedAimInput))
		aimDir = aimDir.linear_interpolate(bufferedAimInput.normalized(), 0.5)
		#print(String(aimDir))
		#aimDir = aimDir.normalized()
		rotation = atan2(aimDir.y, aimDir.x)
		#bufferedAimInput = Vector2()

func fireBullet():
	if bullet.can_instance():
		var newBullet = bullet.instance()
		get_node("/root/Game").add_child(newBullet)
		newBullet.position = get_node("WeaponSprite").global_position
		
		newBullet.lifeTime = weaponRange / weaponBulletSpeed
		newBullet.speed = weaponBulletSpeed
		newBullet.dir = aimDir
		newBullet.rotation = atan2(aimDir.y, aimDir.x)
		
		#lastly, make a test inksplat
		if paintStack.empty():
			refillStack()
		randomSplat()
		#player.inkManager.inkSplat(GroundType.MyInk, global_position + aimDir * weaponRange, 2)
		#print('Bullet fired! Position: '+String(newBullet.position))
	else:
		print("Can't instance bullet?")

func refillStack():
	#put these into a duped array so that we can remove contents over
	#var newPaintDistances = paintDistances.duplicate()
	for i in weaponFireRate + 1:
		paintDistances.append( minPaintDist + i * ((maxPaintDist - minPaintDist)/weaponFireRate))
		
	while not paintDistances.empty():
		var index = randi() % paintDistances.size()
		paintStack.append(paintDistances[index])
		paintDistances.remove(index)

func randomSplat():
	var distance = paintStack.pop_front()
	player.inkManager.inkSplat(GroundType.MyInk, global_position + (aimDir * distance), 2) 
