extends Node

var show_debug: bool = true

func _process(_delta: float) -> void:
	$Overlay/Debug.text = "FPS: " + str(Engine.get_frames_per_second())
	$Overlay/Debug.text += "\nSpeed: " + str(round($Player.speed))
	$Overlay/Debug.text += "\nTurn Speed: " + str(round($Player.turn_radius))

func _input(event):
	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_P:
			if show_debug:
				$Overlay/Debug.hide()
				show_debug = false
			else:
				$Overlay/Debug.show()
				show_debug = true
