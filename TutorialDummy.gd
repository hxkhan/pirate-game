extends CharacterBody2D

var health = 100
var max_health = 100

signal dead_dummy()

func cannon_hit():
	health -= 25
	update_skin()
	if health <= 0:
		await get_tree().create_timer(2).timeout
		visible = false
		await get_tree().create_timer(1).timeout
		visible = true
		health = 100
		update_skin()

func special_hit():
	health -= 100
	update_skin()
	if health <= 0:
		await get_tree().create_timer(2).timeout
		visible = false
		await get_tree().create_timer(1).timeout
		visible = true
		health = 100
		update_skin()

func update_skin():
	var percent = (float(health)/max_health) * 100
	var skin_dir = ""
	if percent <= 0:
		skin_dir = Globals.skin_names["WHITE"][3]
		dead_dummy.emit(1, Vector2(global_position.x, global_position.y-100))
	elif percent <= 25:
		skin_dir = Globals.skin_names["WHITE"][2]
	elif percent <= 75:
		skin_dir = Globals.skin_names["WHITE"][1]
	elif percent == 100:
		skin_dir = Globals.skin_names["WHITE"][0]
	$Sprite.texture = load(skin_dir)
