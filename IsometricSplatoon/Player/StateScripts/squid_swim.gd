extends "res://Player/StateScripts/squidState.gd"

export (float) var swimSpeed = 0
export (float) var swimMaxSpeed = 0


func enter(host):
	host.animPlayer.play('swim')


#func exit(host):
#	return


func handle_input(host, event):
	if event is InputEventKey:
		if event.is_action_released( "swim" ):
			print("swim released!")
			return 'kid_run'
	return .handle_input(host, event)


func update(host, delta):
	host.velocity = host.HandleVelocity(swimSpeed, swimMaxSpeed)
	host.move_and_collide(host.velocity * delta)
	
	if host.velocity.length_squared() == 0:
		return 'squid_idle'
	return .update(host, delta)
