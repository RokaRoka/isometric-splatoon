extends Node2D

onready var player = get_node( ".." )
var bullet = preload("res://Player/Temp/Weapon/bullet.tscn")


#default firing data
var aimDir = Vector2()
var firing = false
var fireCooldown = 0.0
var bulletArray = []


#weapon data
var weaponRange = 256.0 #pixels?? I think?
var weaponBulletSpeed = 384.0 #pixel per second(?)
var weaponFireRate = 6 #shots per second

func _ready():
	fireCooldown = 1.0/weaponFireRate

func _input(event):
	#aim the mouse with keyboard debugging
	if event is InputEventMouseMotion and player.keyboardControl:
		if event.relative.length() > 2: 
			aimDir =  (event.position - player.position).normalized()
			rotation = atan2(aimDir.y, aimDir.x)
	#fire the gun
	if Input.is_action_pressed("fire") and player.canFire:
		startFiring()
	else:
		endFiring()

func _physics_process(delta):
	if fireCooldown <= 1.0/weaponFireRate:
		fireCooldown += delta
	elif firing:
		fireBullet()
		fireCooldown -= 1.0/weaponFireRate

func startFiring():
	firing = true

func endFiring():
	firing = false

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
		player.inkManager.inkSplat(GroundType.MyInk, global_position + aimDir * weaponRange, 2)
		print('Bullet fired! Position: '+String(newBullet.position))
	else:
		print("Can't instance bullet?")
