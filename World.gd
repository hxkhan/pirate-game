extends Node

func _process(_delta: float) -> void:
	$Debug.text = "FPS: " + str(Engine.get_frames_per_second())
	$Debug.text += "\nSpeed: " + str($Player.speed)
	$Debug.text += "\nTurn Speed: " + str($Player.turn_radius)
