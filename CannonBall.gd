extends Area2D

var shot_dir : Vector2 
var speed = 300

var explosion_scene = preload("res://PNG/Default size/Effects/explosion3.png")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += shot_dir * speed * delta

func _on_timer_timeout() -> void:
	$Sprite2D.texture = explosion_scene
	speed = 0
	$ExplosionTimer.start()

func on_explosion_timer_timeout() -> void:
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	$Timer.stop()
	_on_timer_timeout()
