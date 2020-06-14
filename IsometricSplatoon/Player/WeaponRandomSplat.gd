extends Node2D

var size
var inkType

func assignRandomSplat(newPosition, activationTime, newSize = 2, newInkType = GroundType.MyInk):
	global_position = newPosition
	size = newSize
	inkType = newInkType
	$Timer.wait_time = activationTime
	$Timer.start()


func _on_Timer_timeout():
	get_node( "/root/Game/InkManager" ).inkSplat(inkType, global_position, size)
	queue_free()
