extends CharacterBody2D

@export var skin: String = "WHITE"
@export var health: int = 100
@export var max_health: int = 100

func _ready():
	$Sprite.texture = load(Globals.skin_names[skin][0])

func set_health(new_health: int):
	health = new_health
	var percent = (float(health)/max_health) * 100
	var skin_dir = ""
	if percent <= 0:
		skin_dir = Globals.skin_names[skin][3]
	elif percent <= 25:
		skin_dir = Globals.skin_names[skin][2]
	elif percent <= 75:
		skin_dir = Globals.skin_names[skin][1]
	elif percent > 75:
		skin_dir = Globals.skin_names[skin][0]
	$Sprite.texture = load(skin_dir)
