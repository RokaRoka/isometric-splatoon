extends "res://Player/StateScripts/squidState.gd"

export (float) var swimSpeed = 0
export (float) var swimMaxSpeed = 0

export (float) var slowMaxSpeed = 0

func enter(host):
	return .enter(host)


#func exit(host):
#	return


func handle_input(host, event):
	if event is InputEventKey or event is InputEventJoypadButton:
		if event.is_action_released( "swim" ):
			#print("swim released!")
			return 'kid_run'
	return .handle_input(host, event)


func update(host, delta):
	#check for ink before all else
	if host.CheckForMyInk():
		#fast swim swim
		if 'swim' != host.animPlayer.current_animation:
			host.animPlayer.play('swim')
		host.velocity = host.HandleVelocity(swimSpeed, swimMaxSpeed)
		
	else:
		#slow ouch ouch
		if 'octo_move_'+host.lastAnimDir != host.animPlayer.current_animation:
			host.animPlayer.play('octo_move_'+host.lastAnimDir)
		host.velocity = host.HandleVelocity(swimSpeed, slowMaxSpeed)
		
	
	host.move_and_collide(host.velocity * delta)
	
	if host.velocity.length_squared() == 0:
		return 'squid_idle'
	return .update(host, delta)
