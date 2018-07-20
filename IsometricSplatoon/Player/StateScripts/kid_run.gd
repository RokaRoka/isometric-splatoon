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
	return


func exit(host):
	return


func handle_input(host, event):
	if event is InputEventKey or event is InputEventJoypadButton:
		if event.is_action_pressed( "swim" ):
			return 'squid_swim'
	return .handle_input(host, event)


func update(host, delta):
	host.velocity = host.HandleVelocity(runSpeed, runMaxSpeed)
	host.move_and_collide(host.velocity * delta)
	
	#check if move animation is correct
	if 'move_'+host.lastAnimDir != host.animPlayer.current_animation:
		host.animPlayer.play('move_'+host.lastAnimDir)
	
	if host.velocity.length_squared() == 0:
		return 'kid_idle'
	return .update(host, delta)
	
