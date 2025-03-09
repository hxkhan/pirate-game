extends Area2D

signal player_request_explosives(body: Node2D)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_request_explosives.emit(body)
