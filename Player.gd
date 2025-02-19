extends CharacterBody2D

@export var skin: String = "WHITE"
@export var health: int = 100
@export var max_health: int = 100

@export var acceleration: int = 45
@export var max_speed: int = 100
@export var turn_speed: int = 40
@export var drag: int = 20
@export var turn_radius_curve: Curve

signal shoot_cannon(dir_vector:Vector2)
signal shoot_special()
signal we_died()

var turn_radius: float = 0
var speed: float = 0
var last_position: Vector2
var cannon_ball_recharged = true
var special_recharged = true

func _ready() -> void:
	var cursor_texture = load("res://cursor2.png")
	var hotspot = cursor_texture.get_size() / 2
	Input.set_custom_mouse_cursor(cursor_texture, Input.CURSOR_ARROW, hotspot)

func _process(_delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if cannon_ball_recharged:
			var dir_vector = (get_global_mouse_position() - position).normalized()
			shoot_cannon.emit(dir_vector)
			cannon_ball_recharged = false
			$CannonBallTimer.start()
		print("still recharging")
	if event is InputEventKey and event.pressed and special_recharged:
		match event.keycode:
			KEY_E:
				shoot_special.emit(true)
				special_recharged = false
				$SpecialTimer.start()
			KEY_Q:
				shoot_special.emit(false)
				special_recharged = false
				$SpecialTimer.start()

func _physics_process(delta: float) -> void:
	# Detect standstill collision
	if is_on_wall():
		if (last_position - position).length() < 0.1:
			speed = 0
	last_position = position
	
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	
	# Invert x input on reverse
	if speed < 0:
		input_dir.x = -input_dir.x
	
	# Calculate speeed
	speed += acceleration * -input_dir.y * delta
	speed = clamp(speed, -max_speed/3.0, max_speed)
	
	# Calculate drag
	if input_dir.y == 0:
		speed = move_toward(speed, 0, drag * delta)
	
	# Calculate turn_radius
	if speed != 0:
		#turn_radius = turn_speed
		turn_radius = turn_radius_curve.sample(abs(speed/max_speed)) * turn_speed
	else:
		turn_radius = 0
	
	rotation += input_dir.x * deg_to_rad(turn_radius) * delta
	var direction = Vector2(cos(rotation), sin(rotation))
	
	velocity = direction * speed
	move_and_slide()

func _on_cannon_ball_timer_timeout() -> void:
	cannon_ball_recharged = true

func _on_special_timer_timeout() -> void:
	special_recharged = true

func take_damage(amount: int):
	health -= amount
	var percent = (float(health)/max_health) * 100
	var skin_dir = ""
	if percent <= 0:
		skin_dir = Globals.skin_names[skin][3]
		we_died.emit()
	elif percent <= 25:
		skin_dir = Globals.skin_names[skin][2]
	elif percent <= 75:
		skin_dir = Globals.skin_names[skin][1]
	$Sprite.texture = load(skin_dir)
