extends Area2D

var value: int = 0
var dropping_opponent: CharacterBody2D
signal pick_up_frigate_tags(value:int)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body == dropping_opponent:
		return
	if body is CharacterBody2D:
		queue_free()
		if body == get_node("/root/World/Player"):
			pick_up_frigate_tags.emit(value)
