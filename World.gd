extends Node

var show_debug: bool = true
var role_selected: bool = false
var opp = preload("res://Opponent.tscn")
var cannon_ball = preload("res://CannonBall.tscn")

func _ready():
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)

func _process(_delta: float) -> void:
	$Overlay/Debug.text = "FPS: " + str(Engine.get_frames_per_second())
	$Overlay/Debug.text += "\nSpeed: " + str(round($Player.speed))
	$Overlay/Debug.text += "\nTurn Speed: " + str(round($Player.turn_radius))
	
	# Send our own position if we have connected peers
	if role_selected and multiplayer.get_peers():
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
		
		if event.keycode == KEY_H and !role_selected:
			role_selected = true
			$Overlay/Message.hide()
			
			var enet = ENetMultiplayerPeer.new()
			var status = enet.create_server(8869)
			print(error_string(status))
			multiplayer.set_multiplayer_peer(enet)
			
		elif event.keycode == KEY_J and !role_selected:
			role_selected = true
			$Overlay/Message.hide()
			
			var enet = ENetMultiplayerPeer.new()
			var status = enet.create_client("localhost", 8869)
			print(error_string(status))
			multiplayer.set_multiplayer_peer(enet)

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


func on_player_shoot_cannon(dir_vector: Vector2) -> void:
	var cannon_shot = cannon_ball.instantiate()
	cannon_shot.position = $Player.position
	cannon_shot.shot_dir = dir_vector
	add_child(cannon_shot)
