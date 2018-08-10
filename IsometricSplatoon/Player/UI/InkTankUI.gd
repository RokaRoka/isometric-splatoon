extends NinePatchRect

onready var inkBar = $MarginContainer/TextureProgress
#onready var noInk = $MarginContainer/NoInkTexture
#onready var inkRecover = $MarginContainer/RecoverInkTexture

func updateInkUI(ink_amount):
	inkBar.value = (inkBar.max_value - inkBar.min_value) * ink_amount

func _on_TempPlayer_ink_use(ink_left):
	updateInkUI(ink_left)

func _on_TempPlayer_ink_recover(ink_left):
	updateInkUI(ink_left)
	if not $AnimationPlayer.is_playing():
		$AnimationPlayer.play("ink_recover")

func _on_TempPlayer_ink_fail():
	$AnimationPlayer.play("no_ink")
