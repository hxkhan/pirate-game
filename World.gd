extends Node

var assigned_dock_name: String = "DockDelta"
var our_dock: Node2D

var wind_timer: Timer
var currWind: Vector2 = Vector2(0,0)
var show_debug: bool = true
var player = preload("res://Player.tscn")
var opp = preload("res://Opponent.tscn")
var cannon_ball = preload("res://CannonBall.tscn")
var special_attack = preload("res://SpecialAttack.tscn")
var frigate_tag = preload("res://FrigateTag.tscn")

func _ready():
	var cursor_texture = load("res://cursor2.png")
	var hotspot = cursor_texture.get_size() / 2
	Input.set_custom_mouse_cursor(cursor_texture, Input.CURSOR_ARROW, hotspot)
	
	multiplayer.peer_disconnected.connect(peer_disconnected)
	our_dock = get_node(assigned_dock_name)
	our_dock.dead_dock.connect(our_dock_is_dead)
	
	# Spawn ourselves
	var us = player.instantiate()
	us.set_name("Player")
	us.shoot_cannon.connect(on_player_shoot_cannon)
	us.shoot_special.connect(_on_player_shoot_special)
	us.we_died.connect(we_died)
	us.position = our_dock.get_node("Spawn").global_position
	us.rotation = our_dock.rotation
	add_child(us)
	
	# Spawn opps
	for peer in multiplayer.get_peers():
		var inst = opp.instantiate()
		inst.set_name(str(peer))
		add_child(inst)
	
	if multiplayer.is_server():
		wind_timer = Timer.new()
		add_child(wind_timer)
		wind_timer.connect("timeout",Callable(self,"_on_wind_timeout"))
		wind_timer.wait_time = 3.0
		wind_timer.start()
		var rand_angle = randf_range(0, 2 * PI)
		new_wind.rpc(cos(rand_angle), sin(rand_angle));

func _process(_delta: float) -> void:
	$Overlay/Debug.text = "FPS: " + str(Engine.get_frames_per_second())
	$Overlay/Debug.text += "\nSpeed: " + str(round($Player.speed))
	$Overlay/Debug.text += "\nTurn Speed: " + str(round($Player.turn_radius))
	$Overlay/Debug.text += "\nHealth: " + str($Player.health)
	
	# Send our own position if we have connected peers
	if multiplayer.get_peers():
		update_transform.rpc($Player.position, $Player.rotation)

func _input(event):
	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_P:
			if show_debug:
				$Overlay/Debug.hide()
				show_debug = false
			else:
				$Overlay/Debug.show()
				show_debug = true

func peer_disconnected(peer):
	print("Disconnected from peer with ID:", peer)
	get_node(str(peer)).queue_free()
	
	# despawn everyone if server left
	if peer == 1:
		for client in multiplayer.get_peers():
			get_node(str(client)).queue_free()
		multiplayer.multiplayer_peer.close()

@rpc("any_peer", "unreliable_ordered")
func update_transform(pos, rot):
	var id = str(multiplayer.get_remote_sender_id())
	get_node(id).position = pos
	get_node(id).rotation = rot

@rpc("any_peer", "reliable")
func enemy_shoot_cannon(dir_vector: Vector2) -> void:
	var id = str(multiplayer.get_remote_sender_id())
	var cannon_shot = cannon_ball.instantiate()
	cannon_shot.shooter = get_node(id)
	cannon_shot.position = get_node(id).position + dir_vector * 30
	cannon_shot.shot_dir = dir_vector
	cannon_shot.collide.connect(enemy_cannon_collision)
	add_child(cannon_shot)

func on_player_shoot_cannon(dir_vector: Vector2) -> void:
	if multiplayer.get_peers():
		enemy_shoot_cannon.rpc(dir_vector)
	var cannon_shot = cannon_ball.instantiate()
	cannon_shot.shooter = $Player
	cannon_shot.position = $Player.position + dir_vector * 30
	cannon_shot.shot_dir = dir_vector
	add_child(cannon_shot)
	
@rpc("any_peer", "reliable")
func enemy_shoot_special(right_side:bool) -> void:
	var id = str(multiplayer.get_remote_sender_id())
	var shooter = get_node(id)
	var special = special_attack.instantiate()
	if right_side:
		special.position = Vector2(0,50)
	else:
		special.position = Vector2(0,-50)
		special.rotation = deg_to_rad(180)
	special.hit_us.connect(we_have_been_hit_with_special)
	shooter.add_child(special)

func _on_player_shoot_special(right_side: bool) -> void:
	enemy_shoot_special.rpc(right_side)
	var special = special_attack.instantiate()
	if right_side:
		special.position = Vector2(0,50)
	else:
		special.position = Vector2(0,-50)
		special.rotation = deg_to_rad(180)
	$Player.add_child(special)

@rpc("any_peer", "reliable")
func peer_health_update(health: int):
	var id = str(multiplayer.get_remote_sender_id())
	get_node(id).set_health(health)

func enemy_cannon_collision(shot: Area2D, body: Node2D):
	if body == $Player:
		$Player.take_damage(25)
		peer_health_update.rpc($Player.health)
	if body.get_parent() == our_dock:
		our_dock.take_damage(100)

func we_have_been_hit_with_special(body: Node2D):
	if body == $Player:
		$Player.take_damage(50)
		peer_health_update.rpc($Player.health)
	if body.get_parent() == our_dock:
		our_dock.take_damage(500)

@rpc("any_peer","reliable")
func spawn_frigate_tags_for_enemies(tags: int, position: Vector2):
	var frigate_tags = frigate_tag.instantiate()
	frigate_tags.value = tags
	frigate_tags.position = position
	frigate_tags.pick_up_frigate_tags.connect(pick_up_frigate_tags)
	add_child(frigate_tags)

func pick_up_frigate_tags(value: int):
	$Player.frigate_tags += value
	print($Player.frigate_tags)

func we_died():
	spawn_frigate_tags_for_enemies.rpc($Player.frigate_tags, $Player.position)
	if !our_dock.is_dock_alive:
		return
	$Player/Sprite.texture = load(Globals.skin_names[$Player.skin][0])
	$Player.position = our_dock.get_node("Spawn").global_position
	$Player.rotation = our_dock.rotation
	$Player.health = $Player.max_health
	peer_health_update.rpc($Player.health)
	$Player.we_are_dead = false

@rpc("authority","reliable","call_local")
func new_wind(xval: float, yval: float) -> void: 
	currWind = Vector2(xval, yval)

func _on_wind_timeout() -> void:
	var xval = clamp(currWind.x + randf_range(-0.25, 0.25), -1, 1)
	var yval = clamp(currWind.y + randf_range(-0.25, 0.25), -1, 1)
	new_wind.rpc(xval,yval)
	wind_timer.start()

@rpc("any_peer", "reliable")
func enemy_dock_died(dock_name: String):
	print(dock_name + " is now destroyed")
	var destroyed_dock = get_node(dock_name)
	destroyed_dock.queue_free()

func our_dock_is_dead() -> void:
	enemy_dock_died.rpc(our_dock.name)
	$Player.our_dock_is_dead = true
