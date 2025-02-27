extends Node2D

var health = 500
signal sunk()

func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		call_deferred("sink")

func sink():
	$Dock/CollisionShape2D.disabled = true
	$WoodParts.visible = false
	sunk.emit()
