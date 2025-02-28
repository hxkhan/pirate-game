extends Control

var small_world = load("res://WorldSmall.tscn")
var big_world = load("res://World.tscn")

func _ready():
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)

func on_name_next():
	Globals.player_name = $Welcome/NameOption/LineEditName.text
	$Welcome.hide()
	$GameModeOptions.show()

func on_button_ffa_button_up():
	$GameModeOptions.hide()
	$ModeOptions.show()

func on_button_host_up():
	print("Host on :8869")
	var enet = ENetMultiplayerPeer.new()
	var status = enet.create_server(8869)
	print(error_string(status))
	if status == OK:
		multiplayer.set_multiplayer_peer(enet)
		$ModeOptions.hide()
		$Lobby.show()
		var lbl = Label.new()
		lbl.text = "• " + Globals.player_name
		$Lobby/PlayersList.add_child(lbl)

func on_button_join_up():
	$ModeOptions.hide()
	$IPOptions.show()

func on_button_back_from_join_up():
	$IPOptions.hide()
	$ModeOptions.show()

func on_button_start_join_up():
	var ip_address = $IPOptions/LineEditIP.text
	if ip_address != "":
		print("Join " + ip_address + ":" + "8869")
		var enet = ENetMultiplayerPeer.new()
		var status = enet.create_client(ip_address, 8869)
		print(error_string(status))
		if status == OK:
			multiplayer.set_multiplayer_peer(enet)
			$IPOptions.hide()
			$Lobby.show()
			$Lobby/ButtonStart.hide()
			$Lobby/WorldSizeOptions.hide()
			$Lobby/TuneSettings.hide()
			var lbl = Label.new()
			lbl.text = "• " + Globals.player_name
			$Lobby/PlayersList.add_child(lbl)
	else:
		print("Invalid IP Address")

func peer_connected(peer):
	print("Connected to peer with ID:", peer)
	set_player_name.rpc_id(peer, Globals.player_name)
	var lbl = Label.new()
	lbl.text = "• Player " + str(peer)
	lbl.set_name(str(peer))
	$Lobby/PlayersList.add_child(lbl)

func peer_disconnected(peer):
	print("Disconnected from peer with ID:", peer)
	Globals.connected_players.erase(peer)

@rpc("any_peer", "reliable")
func set_player_name(name: String):
	var peer = multiplayer.get_remote_sender_id()
	Globals.connected_players[peer] = name
	$Lobby/PlayersList.get_node(str(peer)).text = "• " + name

func on_start_game():
	Globals.max_speed = int($Lobby/TuneSettings/MaxSpeed/LineEdit.text)
	Globals.turn_speed = float($Lobby/TuneSettings/TurnSpeed/LineEdit.text)
	Globals.drag = float($Lobby/TuneSettings/Drag/LineEdit.text)
	Globals.cannon_delay = float($Lobby/TuneSettings/CannonDelay/LineEdit.text)
	
	var docks = ["DockAlpha", "DockBeta", "DockCharlie", "DockDelta"]
	docks.shuffle()
	
	var map = "small"
	if $Lobby/WorldSizeOptions/BigWorldType/CheckButton.button_pressed:
		map = "big"
	
	var world_instance 
	if map == "small":
		world_instance = small_world.instantiate()
	else:
		world_instance = big_world.instantiate()
		
	world_instance.assigned_dock_name = docks[0]
	
	# Assign docks to each player
	var i = 1
	for peer in multiplayer.get_peers():
		start_game.rpc_id(peer, map, docks[i], Globals.max_speed, Globals.turn_speed, Globals.drag, Globals.cannon_delay)
		i += 1
	
	# Change scene
	get_tree().root.add_child(world_instance)
	get_tree().current_scene.queue_free()
	get_tree().set_current_scene(world_instance)


@rpc("authority", "reliable")
func start_game(map: String, dock_name: String, max_speed: int, turn_speed: int, drag: int, cannon_delay: float):
	Globals.max_speed = max_speed
	Globals.turn_speed = turn_speed
	Globals.drag = drag
	Globals.cannon_delay = cannon_delay
	
	var world_instance 
	if map == "small":
		world_instance = small_world.instantiate()
	else:
		world_instance = big_world.instantiate()
		
	world_instance.assigned_dock_name = dock_name
	get_tree().root.add_child(world_instance)
	get_tree().current_scene.queue_free()
	get_tree().set_current_scene(world_instance)
