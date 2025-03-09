extends Area2D

@export var expl_owner : CharacterBody2D

signal explosive_hit_us(who: Node2D)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body == expl_owner:
		return
	if body is CharacterBody2D:
		if body.name == "Player":
			explosive_hit_us.emit(expl_owner)
			pass
		queue_free()
