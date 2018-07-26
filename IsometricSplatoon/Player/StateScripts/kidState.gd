extends "res://General/Scripts/states.gd"

#The Kid state repsents when an Inkling is in it's default state
var inkRecoverSpeed = 10.0 #how many seconds to recover

func enter(host):
	host.ShowWeapon()
	return .enter(host)


func exit(host):
	return .exit(host)


func handle_input(host, event):
	return .handle_input(host, event)


func update(host, delta):
	host.RecoverInk(delta, inkRecoverSpeed, false)
	return .update(host, delta)
