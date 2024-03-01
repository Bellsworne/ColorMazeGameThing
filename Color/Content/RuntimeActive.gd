extends Node3D

class_name Runtime

@onready var player : Player = get_node("Player")

var level : int = 2

var orb_count : int

func _ready():
	Master.current_runtime = self
