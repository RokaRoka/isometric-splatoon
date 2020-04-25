extends "res://Player/StateScripts/kidState.gd"

#The Kid Run state
#From here, the Inkling can:
	#Idle (Changes state)
	#Squid-form (Changes state)
	#Fire (affects weapon)
	#Sub (affects weapon)
	#Aim (affects UI/camera)

export (float) var runSpeed = 0
export (float) var runMaxSpeed = 0


func enter(host):
	#host.animPlayer.play('move_'+host.lastAnimDir)
	print("Entering run")
	return .enter(host)


func exit(host):
	return .exit(host)


func handle_input(host, event):
	if event is InputEventKey or event is InputEventJoypadButton:
		if event.is_action_pressed( "swim" ):
			return 'squid_swim'
	return .handle_input(host, event)


func update(host, delta):
	host.velocity = host.HandleVelocity(runSpeed, runMaxSpeed)
	host.move_and_collide(host.velocity * delta)
	
	#check if move animation is correct
	if host.weapon.firing:
		var animDir = "nil"
		var normalRot = host.weapon.rotation_degrees
		if normalRot > -25 and normalRot < 25:
			animDir = "e"
		elif normalRot > 25 and normalRot < 65:
			animDir = "se"
		elif normalRot > 65 and normalRot < 115:
			animDir = "s"
		elif normalRot > 115 and normalRot < 155:
			animDir = "sw"
		elif normalRot > 155 and normalRot < -155:
			animDir = "w"
		elif normalRot > -155 and normalRot < -115:
			animDir = "nw"
		elif normalRot > -115 and normalRot < -65:
			animDir = "n"
		elif normalRot > -65 and normalRot < -25:
			animDir = "ne"
		if 'shoot_'+animDir != host.animPlayer.current_animation:
			host.animPlayer.play('shoot_'+animDir)
	elif 'move_'+host.lastAnimDir != host.animPlayer.current_animation:
		host.animPlayer.play('move_'+host.lastAnimDir)
	
	if host.velocity.length_squared() == 0:
		return 'kid_idle'
	return .update(host, delta)
	
