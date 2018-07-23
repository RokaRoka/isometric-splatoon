extends "res://Player/StateScripts/squidState.gd"


func enter(host):
	if host.animPlayer.current_animation != 'swim':
		print('switching to swim anim')
		host.animPlayer.play('swim')
		print('current anim: '+host.animPlayer.current_animation)
	host.animPlayer.stop()
	host.velocity = Vector2()
	print("Entering squid idle")
	return .enter(host)


#func exit(host):
#	return


func handle_input(host, event):
	if event is InputEventKey or event is InputEventJoypadButton:
		if event.is_action_released( "swim" ):
			print("squid idle released!")
			return 'kid_idle'
	return .handle_input(host, event)


func update(host, delta):
	#check for ink before all else
	if host.CheckForMyInk():
		#fast swim swim
		if 'swim' != host.animPlayer.current_animation:
			host.animPlayer.play('swim')
			host.animPlayer.stop()
	else:
		#slow ouch ouch
		if 'octo_move_'+host.lastAnimDir != host.animPlayer.current_animation:
			host.animPlayer.play('octo_move_'+host.lastAnimDir)
			host.animPlayer.stop()
	
	if host.inputDir.length() > host.deadZone:
		return 'squid_swim'
	return .update(host, delta)


#func _on_animation_finished(anim_name):
#	return