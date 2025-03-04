extends Area2D

@export var value: int = 0
signal pick_tags(value: int)

func on_body_entered(body):
	if body is CharacterBody2D:
		if body.is_dead(): return
		if body.name == "Player":
			pick_tags.emit(value)
		queue_free()
