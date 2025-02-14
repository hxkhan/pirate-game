extends Area2D

var shot_dir : Vector2
var shooter : CharacterBody2D
var speed = 200
var damage = 50

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += shot_dir * speed * delta

func on_timer_timeout() -> void:
	speed = 0
	$AnimationPlayer.play("contact_solid")

func on_body_entered(body: Node2D) -> void:
	if body == shooter:
		return
	if body is CharacterBody2D or body.name == "Dock":
		on_timer_timeout()

func on_animation_finished(name):
	if name == "contact_solid":
		queue_free()
