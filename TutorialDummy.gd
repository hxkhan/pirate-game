extends Area2D

var health = 100
signal dead_dummy()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if health <= 0:
		dead_dummy.emit(1, global_position)
		visible = false
		health = 100
		$Timer.start()

func _on_area_entered(area: Area2D) -> void:
	health -= 25


func _on_timer_timeout() -> void:
	visible = true
