extends "res://General/Scripts/states.gd"

#The Kid state repsents when an Inkling is in it's default state


func enter(host):
	host.canFire = true
	return .enter(host)


func exit(host):
	#host.canFire = false
	return .exit(host)


func handle_input(host, event):
	return .handle_input(host, event)


#func update(host, delta):
#	return
