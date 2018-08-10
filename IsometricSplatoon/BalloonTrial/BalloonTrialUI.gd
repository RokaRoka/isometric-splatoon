extends NinePatchRect

onready var balloonText = get_node("CenterContainer/VBoxContainer/BalloonText")
onready var timerText = get_node("CenterContainer/VBoxContainer/TimerText")

var defaultTimerText = "%s s"
var defaultBalloonText = "%s / 15"
var digitAmount = 2

func UpdateBalloonCount(newBalloonNum):
	balloonText.text = defaultBalloonText % str(newBalloonNum)

func UpdateTimer(newTime):
	newTime = str(newTime).pad_decimals(digitAmount)
	timerText.text = defaultTimerText % newTime

func _on_BalloonTrialManager_balloon_score_update(newScore):
	UpdateBalloonCount(newScore)


func _on_BalloonTrialManager_timer_update(newTime):
	UpdateTimer(newTime)
