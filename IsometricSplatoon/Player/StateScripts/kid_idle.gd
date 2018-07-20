extends "res://Player/StateScripts/kidState.gd"

#The Kid Idle state
#From here, the Inkling can:
	#Run (Changes state)
	#Squid-form (Changes state)
	#Fire (affects weapon)
	#Sub (affects weapon)
	#Aim (affects UI/camera)


func enter(host):
	host.animPlayer.play('move_'+host.lastAnimDir)
	host.animPlayer.stop()
	host.velocity = Vector2()
	print("Entering idle")
	return


#func exit(host):
#	return


func handle_input(host, event):
	if event is InputEventKey or event is InputEventJoypadButton:
		if event.is_action_pressed( "swim" ):
			return 'squid_idle'
	return .handle_input(host, event)


func update(host, delta):
	if host.inputDir.length() > host.deadZone:
		return 'kid_run'
	return


#func _on_animation_finished(anim_name):
#	return