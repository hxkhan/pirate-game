extends CharacterBody2D

@export var skin: String = "WHITE"
@export var health: int = 100
@export var max_health: int = 100

@export var input_disabled: bool = false

@export var acceleration: int = 60
@export var max_speed: int = 160
@export var turn_speed: int = 45
@export var drag: int = 20
@export var turn_radius_curve: Curve

signal shoot_cannon(dir_vector:Vector2)
signal shoot_special(right_side: bool)
signal we_died(by: CharacterBody2D)

var speed: float = 0
var last_position: Vector2

var cannon_ball_recharged = true
var special_recharged = true

var cannon_ball_delay: float = 0.75
var special_delay: float = 15

var frigate_tags: int = 1

func _ready():
	$Camera.make_current()
	$Sprite.texture = load(Globals.skin_names[skin][0])

func _input(event: InputEvent) -> void:
	if health <= 0 or input_disabled:
		return
	
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if cannon_ball_recharged:
			cannon_ball_recharged = false
			var dir_vector = (get_global_mouse_position() - position).normalized()
			shoot_cannon.emit(dir_vector)
			
			# Reload cannon
			await get_tree().create_timer(cannon_ball_delay).timeout
			cannon_ball_recharged = true
			
	if event is InputEventKey and event.pressed and special_recharged and (event.keycode == KEY_E or event.keycode == KEY_Q):
		special_recharged = false
		shoot_special.emit(true if event.keycode == KEY_E else false)
		
		# Reload special
		await get_tree().create_timer(special_delay).timeout
		special_recharged = true

func _physics_process(delta: float) -> void:
	# Detect standstill collision
	if is_on_wall():
		if (last_position - position).length() < 0.1:
			# allow player to come out of a corner without reversing like feedback said
			speed = clamp(speed, -50/3, 50)
	last_position = position
	
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	if health <= 0 or input_disabled:
		input_dir = Vector2(0, 0)
	
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
	var turn_radius = turn_radius_curve.sample(abs(speed/max_speed)) * turn_speed
	
	rotation += input_dir.x * deg_to_rad(turn_radius) * delta
	var direction = Vector2(cos(rotation), sin(rotation))
	
	var dot_prod = direction.dot(get_parent().currWind)
	velocity = direction * speed + direction * speed * dot_prod * 0.2
	move_and_slide()

func take_damage(amount: int, by: CharacterBody2D):
	# don't continue to take damage
	if health <= 0:
		return
	
	health -= amount
	var percent = (float(health)/max_health) * 100
	var skin_dir = ""
	if percent <= 0:
		skin_dir = Globals.skin_names[skin][3]
	elif percent <= 25:
		skin_dir = Globals.skin_names[skin][2]
	elif percent <= 75:
		skin_dir = Globals.skin_names[skin][1]
	$Sprite.texture = load(skin_dir)
	
	if health <= 0:
		we_died.emit(by)

func is_dead():
	return health <= 0

func reset(dock: Node2D):
	$Sprite.texture = load(Globals.skin_names[skin][0])
	frigate_tags = 1
	position = dock.get_node("Spawn").global_position
	rotation = dock.rotation
	health = max_health
