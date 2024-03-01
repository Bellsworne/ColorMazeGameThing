extends InteractiveItem
class_name Orb
@onready var Orb_Mesh : MeshInstance3D = get_node("MeshInstance3D")
@onready var Light : OmniLight3D = get_node("OmniLight3D")
enum _COLOR {
	RED, GREEN, BLUE, GOLD, RAINBOW
	#RED = 1,
	#GREEN = 2,
	#BLUE = 4,
	#GOLD = 8,
	#RAINBOW = 16
}

var index_colors : Array[String] = ["ff0000", "00ff00", "0000ff", "917505", "d4008b"]

@export var color : _COLOR = _COLOR.RED

func _ready() -> void:
	var mat : StandardMaterial3D = StandardMaterial3D.new()
	Orb_Mesh.set_surface_override_material(0, mat)
	mat.albedo_color = Color(index_colors[color])
	Light.light_color = Color(index_colors[color])

