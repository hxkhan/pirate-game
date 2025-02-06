extends Area2D

var shot_dir : Vector2 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += shot_dir * 300 * delta

func _on_timer_timeout() -> void:
	queue_free()
