extends Area2D

@export var value: int = 0
signal player_collide(value: int, tags: Area2D)

func on_body_entered(body):
	if body is CharacterBody2D and body.name == "Player":
		player_collide.emit(self)
