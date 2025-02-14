extends Control

var world_scene = load("res://World.tscn")
var world_instance = world_scene.instantiate()

func on_button_ffa_button_up():
	$GameModeOptions.hide()
	$ModeOptions.show()

func on_button_host_up():
	world_instance.host = true
	get_tree().root.add_child(world_instance)  # Add instance to the scene tree
	get_tree().current_scene.queue_free()  # Remove current scene
	get_tree().set_current_scene(world_instance)  # Switch to the new scene

func on_button_join_up():
	$ModeOptions.hide()
	$IPOptions.show()

func on_button_back_from_join_up():
	$IPOptions.hide()
	$ModeOptions.show()

func on_button_start_join_up():
	var ip_address = $IPOptions/LineEditIP.text
	if ip_address != "":
		world_instance.ip_address = ip_address
		world_instance.host = false
		get_tree().root.add_child(world_instance)  # Add instance to the scene tree
		get_tree().current_scene.queue_free()  # Remove current scene
		get_tree().set_current_scene(world_instance)  # Switch to the new scene
	else:
		print("Invalid IP Address")
