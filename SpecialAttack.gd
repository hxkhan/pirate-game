extends Area2D

@export var performer: CharacterBody2D

signal hit_us(who: Node2D)

signal hit_dummy()

func _ready() -> void:
	$AnimationPlayer.play("perform")

func on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		if body.name == "Player":
			hit_us.emit(performer)
		elif body.name == "TutorialDummy":
			hit_dummy.emit()

func on_animation_finished(anim_name):
	if anim_name == "perform":
		queue_free()
