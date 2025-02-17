extends Node

var white_ships: Array[String] = [
	"res://PNG/Default size/Ships/ship (1).png",
	"res://PNG/Default size/Ships/ship (7).png",
	"res://PNG/Default size/Ships/ship (13).png",
	"res://PNG/Default size/Ships/ship (19).png"
]

var black_ships: Array[String] = [
	"res://PNG/Default size/Ships/ship (2).png",
	"res://PNG/Default size/Ships/ship (8).png",
	"res://PNG/Default size/Ships/ship (14).png",
	"res://PNG/Default size/Ships/ship (20).png"
]

var red_ships: Array[String] = [
	"res://PNG/Default size/Ships/ship (3).png",
	"res://PNG/Default size/Ships/ship (9).png",
	"res://PNG/Default size/Ships/ship (15).png",
	"res://PNG/Default size/Ships/ship (21).png"
]

var green_ships: Array[String] = [
	"res://PNG/Default size/Ships/ship (4).png",
	"res://PNG/Default size/Ships/ship (10).png",
	"res://PNG/Default size/Ships/ship (16).png",
	"res://PNG/Default size/Ships/ship (22).png"
]

var blue_ships: Array[String] = [
	"res://PNG/Default size/Ships/ship (5).png",
	"res://PNG/Default size/Ships/ship (11).png",
	"res://PNG/Default size/Ships/ship (17).png",
	"res://PNG/Default size/Ships/ship (23).png"
]

var yellow_ships: Array[String] = [
	"res://PNG/Default size/Ships/ship (6).png",
	"res://PNG/Default size/Ships/ship (12).png",
	"res://PNG/Default size/Ships/ship (18).png",
	"res://PNG/Default size/Ships/ship (24).png"
]

var skin_names: Dictionary = {
	"WHITE": white_ships,
	"BLACK": black_ships,
	"RED": red_ships,
	"GREEN": green_ships,
	"BLUE": blue_ships,
	"YELLOW": yellow_ships
}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
