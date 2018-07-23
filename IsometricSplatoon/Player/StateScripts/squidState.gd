extends "res://General/Scripts/states.gd"

#  The Squid state repsents when an Inkling is in it's squid state which
#  allows for fast movement in ink. However, outside of ink, being in squid
#  form makes the player vulnerable and slow. Players have to pick and choose.


func enter(host):
	host.weapon.endFiring()
	host.canFire = false
	return .enter(host)


#func exit(host):
#	return


func handle_input(host, event):
	return .handle_input(host, event)


#func update(host, delta):
#	return
