extends Node2D

var curr_sprite = 1

var sprite2 = preload("res://PNG/Kenney Particle Pack/magic_02.png")
var sprite3 = preload("res://PNG/Kenney Particle Pack/magic_03.png")
var sprite4 = preload("res://PNG/Kenney Particle Pack/magic_04.png")
var sprite5 = preload("res://PNG/Kenney Particle Pack/magic_05.png")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$SpawnTimer.start()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_spawn_timer_timeout() -> void:
	if curr_sprite == 1:
		curr_sprite = curr_sprite + 1
		$Magic.texture = sprite2
	elif curr_sprite == 2:
		curr_sprite = curr_sprite + 1
		$Magic.texture = sprite3
	elif curr_sprite == 3:
		curr_sprite = curr_sprite + 1
		$Magic.texture = sprite4
	elif curr_sprite == 4:
		curr_sprite = curr_sprite + 1
		$Magic.texture = sprite5
	else:
		queue_free()
	$SpawnTimer.start()
