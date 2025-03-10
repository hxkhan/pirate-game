extends Area2D

var health = 100
signal dead_dummy()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if health <= 0:
		dead_dummy.emit(1, global_position)
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	health -= 25
