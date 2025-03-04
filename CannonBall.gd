extends Area2D

var shot_dir : Vector2
var shooter : CharacterBody2D
var speed = 250
var damage = 50
var has_exploded: float

signal hit_us(shooter: CharacterBody2D)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !has_exploded:
		var direction = shot_dir.dot(get_parent().currWind)
		position += shot_dir * speed * delta + shot_dir * direction * 0.3

func on_timer_timeout() -> void:
	has_exploded = true
	$AnimationPlayer.play("contact_solid")

func on_body_entered(body: Node2D) -> void:
	if body == shooter:
		return
	if body is CharacterBody2D:
		on_timer_timeout()
		if body.name == "Player":
			hit_us.emit(shooter)

func on_animation_finished(name):
	if name == "contact_solid":
		queue_free()
