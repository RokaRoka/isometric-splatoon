extends Node2D

func assignRandomSplat(newPosition, activationTime):
	global_position = newPosition
	$Timer.wait_time = activationTime
	$Timer.start()


func _on_Timer_timeout():
	get_node( "/root/Game/InkManager" ).inkSplat(GroundType.MyInk, global_position, 2)
	queue_free()
