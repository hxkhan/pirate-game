extends Node2D

var hp = 500
var is_dock_alive = true
signal dead_dock()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_dock_alive and hp <= 0:
		is_dock_alive = false
		$Dock/CollisionShape2D.disabled = true
		$WoodParts.visible = false
		dead_dock.emit()


func take_damage(amount: int) -> void:
	hp -= amount
