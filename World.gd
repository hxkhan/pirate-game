extends Node

var assigned_dock_name: String = "DockDelta"
var our_dock: Node2D
var our_kills: int = 0

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
	our_dock.sunk.connect(
		func():
			dock_sunk.rpc(assigned_dock_name)
	)
	
	# Spawn ourselves
	var us = player.instantiate()
	us.set_name("Player")
	us.shoot_cannon.connect(we_shot_cannon)
	us.shoot_special.connect(we_shot_special)
	us.we_died.connect(we_died)
	us.position = our_dock.get_node("Spawn").global_position
	us.rotation = our_dock.rotation
	us.our_dock = our_dock
	add_child(us)
	
	# Spawn opps
	for peer in multiplayer.get_peers():
		var inst = opp.instantiate()
		inst.set_name(str(peer))
		add_child(inst)
	
	if multiplayer.is_server():	
		# wind
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
	$Overlay/Debug.text += "\nDock Health: " + str(our_dock.health)
	$Overlay/Debug.text += "\nFrigate Tags: " + str($Player.frigate_tags)
	$Overlay/Debug.text += "\nKills: " + str(our_kills)
	$Overlay/Debug.text += "\nTime Left: " + str(round($MatchTimer.time_left))
	$Overlay/Debug.text += "\nWind dir: " + str(currWind.x) + ", " + str(currWind.y)
	
	$Overlay/WindArrow.rotation = atan2(currWind.y, currWind.x)
	
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

func we_shot_cannon(dir_vector: Vector2) -> void:
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

func we_shot_special(right_side: bool) -> void:
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
		$Player.take_damage(25, shot.shooter)
		peer_health_update.rpc($Player.health)
	if body.get_parent() == our_dock:
		our_dock.take_damage(100)

func we_have_been_hit_with_special(body: Node2D):
	if body == $Player:
		$Player.take_damage(50)
		peer_health_update.rpc($Player.health)
	if body.get_parent() == our_dock:
		our_dock.take_damage(250)

@rpc("any_peer","reliable")
func spawn_frigate_tags_for_enemies(tags: int, position: Vector2):
	var id = str(multiplayer.get_remote_sender_id())
	var frigate_tags = frigate_tag.instantiate()
	frigate_tags.value = tags
	frigate_tags.position = position
	frigate_tags.dropping_opponent = get_node(id)
	frigate_tags.pick_up_frigate_tags.connect(pick_up_frigate_tags)
	add_child(frigate_tags)

func pick_up_frigate_tags(value: int):
	$Player.frigate_tags += value
	print($Player.frigate_tags)

func we_died(by: CharacterBody2D):
	kill_confirmed.rpc_id(int(str(by.name)))
	spawn_frigate_tags_for_enemies.rpc($Player.frigate_tags, $Player.position)
	$Player.frigate_tags = 1
	# cannot respawn
	if our_dock.health <= 0:
		$Player.input_disabled = true
		return
	$Player.reset()
	peer_health_update.rpc($Player.health)

@rpc("authority","reliable","call_local")
func new_wind(xval: float, yval: float) -> void: 
	currWind = Vector2(xval, yval)

func _on_wind_timeout() -> void:
	var xval = clamp(currWind.x + randf_range(-0.25, 0.25), -1, 1)
	var yval = clamp(currWind.y + randf_range(-0.25, 0.25), -1, 1)
	new_wind.rpc(xval,yval)
	wind_timer.start()

@rpc("any_peer", "reliable")
func dock_sunk(dock_name: String):
	print(dock_name + " is now destroyed")
	var destroyed_dock = get_node(dock_name)
	destroyed_dock.take_damage(500)

@rpc("any_peer", "reliable")
func kill_confirmed():
	our_kills += 1

@rpc("any_peer", "reliable")
func inform_stats(kills: int):
	var id = multiplayer.get_remote_sender_id()
	var container = HBoxContainer.new()
	var left = Label.new()
	left.text = Globals.connected_players[id]
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var right = Label.new()
	right.text = str(kills)
	container.add_child(left)
	container.add_child(right)
	$Overlay/EndGame/Leaderboards.add_child(container)

func on_match_finish():
	$Player.input_disabled = true
	$Overlay/EndGame.show()
	inform_stats.rpc(our_kills)
	$Overlay/EndGame/Leaderboards/Us/Kills.text = str(our_kills)
	$Overlay/EndGame/Leaderboards/Us/Name.text = Globals.player_name
