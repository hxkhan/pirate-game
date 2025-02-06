extends CharacterBody2D

@export var acceleration: int = 45
@export var max_speed: int = 100
@export var turn_speed: int = 40
@export var drag: int = 20
@export var turn_radius_curve: Curve

signal shoot_cannon(dir_vector:Vector2)

var turn_radius: float = 0
var speed: float = 0

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var dir_vector = (get_global_mouse_position() - position).normalized()
		shoot_cannon.emit(dir_vector)

func _physics_process(delta: float) -> void:
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
