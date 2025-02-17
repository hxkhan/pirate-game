extends Node

@export var ip_address: String
@export var host: bool

var show_debug: bool = true
var opp = preload("res://Opponent.tscn")
var cannon_ball = preload("res://CannonBall.tscn")
var special_attack = preload("res://SpecialAttack.tscn")

func _ready():
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	
	if host:
		$Overlay/Message.hide()
		print("Host on :8869")
		var enet = ENetMultiplayerPeer.new()
		var status = enet.create_server(8869)
		print(error_string(status))
		multiplayer.set_multiplayer_peer(enet)
	else:
		$Overlay/Message.hide()
		print("Join " + ip_address + ":" + "8869")
		var enet = ENetMultiplayerPeer.new()
		var status = enet.create_client(ip_address, 8869)
		print(error_string(status))
		multiplayer.set_multiplayer_peer(enet)

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

func peer_connected(peer):
	print("Connected to peer with ID:", peer)
	
	# spawn player
	var inst = opp.instantiate()
	inst.set_name(str(peer))
	add_child(inst)

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
	cannon_shot.hit_us.connect(we_have_been_hit_with_cannon)
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
func request_change_skin(skin_dir: String):
	var id = str(multiplayer.get_remote_sender_id())
	get_node(id).get_node("Sprite").texture = load(skin_dir)

func we_have_been_hit_with_cannon():
	var skin_dir = $Player.take_damage(25)
	request_change_skin.rpc(skin_dir)

func we_have_been_hit_with_special():
	var skin_dir = $Player.take_damage(50)
	request_change_skin.rpc(skin_dir)
