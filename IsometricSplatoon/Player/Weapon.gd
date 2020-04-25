extends Node2D

#refs
onready var player = get_node( ".." )
onready var reticle = get_node("ReticleSprite")

var bullet = preload("res://Player/Temp/Weapon/bullet.tscn")
var timedInkSplat = preload("res://Player/Temp/Weapon/TimedSplat.tscn")

#default firing data
var bufferedAimInput = Vector2()
var aimDir = Vector2()
var firing = false
var fireCooldown = 0.0
var currentWeaponRange = 0

#weapon data
var minWeaponRange = 96.0
var maxWeaponRange = 256.0 #pixels?? I think?
var bulletOffset = 32
var weaponBulletSpeed = 432.0 #pixel per second(?)
var weaponFireRate = 10.0 #shots per second
var inkConsume = 0.01 # out of 1
var damageDirect = 35.0

#paint data
var minPaintDist = 16
var maxPaintDistDiff = 16 # amount subtracted from current weapon range for max paint range. Complicated, I know
var paintDistances = [] #paint distances are in fractions
var paintStack = []

func _ready():
	currentWeaponRange = maxWeaponRange
	
	fireCooldown = 1.0/weaponFireRate
	refillStack()

func _input(event):
	#aim the mouse with keyboard debugging
	if event is InputEventMouseMotion and player.keyboardControl:
		if event.relative.length_squared() > 2:
			#var mouseDist = (event.position - player.position).length()
			#currentWeaponRange = clamp(mouseDist, minWeaponRange, maxWeaponRange)
			var aimDistance = (event.position - player.position)
			#print("Aim dist is: "+str(aimDistance))
			#print("Aim length is: "+str(aimDistance.length()))
			if aimDistance.length()/maxWeaponRange < 1:
				bufferedAimInput = aimDistance/maxWeaponRange
			else:
				bufferedAimInput = aimDistance
	elif event is InputEventJoypadMotion and event.is_action("aim"):
		if event.axis == JOY_AXIS_2: #and abs(event.axis_value) > player.deadZone:
			bufferedAimInput.x = event.axis_value
		elif event.axis == JOY_AXIS_3: #and abs(event.axis_value) > player.deadZone:
			bufferedAimInput.y = event.axis_value
	#fire the gun
	if Input.is_action_pressed("fire") and player.canFire and player.mouseControl:
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

func getAimDir():
	return rotation

func updateAim():
	var dist = bufferedAimInput.length()
	if dist > player.deadZone:
		#set weapon range based on dist
		currentWeaponRange = clamp(dist * maxWeaponRange, minWeaponRange, maxWeaponRange)
		#print("dist is: "+str(dist)+ ". clamped weapon range is: "+str(currentWeaponRange))
		
		#set aim direction and rotation of weapon
		aimDir = aimDir.linear_interpolate(bufferedAimInput.normalized(), 0.5)
		rotation = atan2(aimDir.y, aimDir.x)
		
		#update reticle (considering the 24 subtracted from max range)
		reticle.position.x = currentWeaponRange
		reticle.self_modulate.a = clamp((currentWeaponRange + 48) / maxWeaponRange, 0, 1.0)		

func fireBullet():
	if bullet.can_instance() and timedInkSplat.can_instance() and player.TryUseInk(inkConsume):
		var newBullet = bullet.instance()
		get_node("/root/Game").add_child(newBullet)
		newBullet.position = global_position + (aimDir * bulletOffset)
		
		#set direction correctly
		newBullet.lifeTime = currentWeaponRange / weaponBulletSpeed
		newBullet.speed = weaponBulletSpeed
		newBullet.dir = aimDir
		newBullet.rotation = atan2(aimDir.y, aimDir.x)
		
		#set damage
		newBullet.damageDirect = damageDirect
		
		#lastly, make a paint inksplat
		if paintStack.empty():
			refillStack()
		var newTimedInkSplat = timedInkSplat.instance()
		get_node("/root/Game").add_child(newTimedInkSplat)
		newTimedInkSplat.assignRandomSplat(getRandomSplatPosition(), currentWeaponRange/weaponBulletSpeed)
		
	else:
		print("Can't instance bullet or Not enough ink")

func refillStack():
	#put these into a duped array so that we can remove contents over
	#var newPaintDistances = paintDistances.duplicate()
	for i in weaponFireRate + 1:
		paintDistances.append(i/weaponFireRate)
	
	while not paintDistances.empty():
		var index = randi() % paintDistances.size()
		paintStack.append(paintDistances[index])
		paintDistances.remove(index)

func getRandomSplatPosition():
	var distance = minPaintDist + (paintStack.pop_front() * ((currentWeaponRange - maxPaintDistDiff) - minPaintDist))
	return global_position + (aimDir * distance)
	#player.inkManager.inkSplat(GroundType.MyInk, , 2)
