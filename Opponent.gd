extends CharacterBody2D

@export var skin: String = "WHITE"
@export var max_health: int = 100
@export var health: int = 100:
	set(value):
		health = clamp(value, 0, max_health)
		var percent = (float(health) / max_health) * 100
		var skin_dir = ""
		
		if percent > 0 and $CollisionShape.disabled:
			$CollisionShape.set_deferred("disabled", false)
		
		if percent <= 0:
			skin_dir = Globals.skin_names[skin][3]
			$CollisionShape.disabled = true
		elif percent <= 25:
			skin_dir = Globals.skin_names[skin][2]
		elif percent <= 75:
			skin_dir = Globals.skin_names[skin][1]
		else:
			skin_dir = Globals.skin_names[skin][0]
		
		$Sprite.texture = load(skin_dir)

func is_dead():
	return health <= 0
