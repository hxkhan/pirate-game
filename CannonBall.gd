extends Area2D

var shot_dir : Vector2
var shooter : CharacterBody2D
var speed = 300
var damage = 50

var explosion_scene1 = preload("res://PNG/Default size/Effects/explosion1.png")
var explosion_scene2 = preload("res://PNG/Default size/Effects/explosion2.png")
var explosion_scene3 = preload("res://PNG/Default size/Effects/explosion3.png")
var scene_num = 2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += shot_dir * speed * delta

func _on_timer_timeout() -> void:
	$Sprite2D.texture = explosion_scene1
	speed = 0
	$ExplosionTimer.start()

func on_explosion_timer_timeout() -> void:
	if scene_num == 2:
		$Sprite2D.texture = explosion_scene2
		scene_num = scene_num - 1
		$ExplosionTimer.start()
	elif scene_num == 1:
		$Sprite2D.texture = explosion_scene3
		scene_num = scene_num - 1
		$ExplosionTimer.start()
	else:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body == shooter:
		return
	if body is CharacterBody2D or body.name == "Dock":
		$Timer.stop()
		_on_timer_timeout()
