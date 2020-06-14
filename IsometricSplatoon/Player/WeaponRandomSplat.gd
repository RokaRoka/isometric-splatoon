extends Node2D

var size
var inkType

func assignRandomSplat(newPosition, activationTime, newSize = 2, newInkType = InkManager.GroundType.MY_INK):
	global_position = newPosition
	size = newSize
	inkType = newInkType
	$Timer.wait_time = activationTime
	$Timer.start()


func _on_Timer_timeout():
	InkManager.inkSplat(inkType, global_position, size)
	queue_free()
