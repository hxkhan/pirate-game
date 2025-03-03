extends Area2D

var value: int = 0
signal pick_up_frigate_tags(value:int)

var can_be_picked_up: bool = false

func _ready():
	await get_tree().create_timer(0.1).timeout
	can_be_picked_up = true

func on_body_entered(body):
	if body is CharacterBody2D and body.name == "Player" and can_be_picked_up:
		pick_up_frigate_tags.emit(value)
		queue_free()
