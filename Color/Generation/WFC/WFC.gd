extends Node3D
class_name MazeGenerator

@onready var orb_spawner : Node3D = get_parent().get_node("OrbSpawner")

const orb_scene = preload("res://Content/Orb/Orb.tscn")
@export var tilemap : GridMap
@export var level : int = 2
@export var map_width : int = 8 * level
@export var map_height : int = 8 * level

const TILE_BLOCK = 0

var rng : RandomNumberGenerator = RandomNumberGenerator.new()

func _ready():
	generate()

func generate():
	generate_border()
	generate_inner()
	generate_orbs()
	var orbs : Array = generate_orbs(level * 2)
	#(Master.current_runtime as Runtime).orb_count = orbs.size()

func generate_border() -> void:
	for x in range(map_width):
		for y in range(map_height):
			if x == 0 or x == map_width - 1 or y == 0 or y == map_height - 1:
				tilemap.set_cell_item(Vector3(x, 0, y), TILE_BLOCK)
	for x in range(1, map_width - 2):
		for y in range(1, map_height - 2):
			if x % 2 == 0 and y % 2 == 0:
				tilemap.set_cell_item(Vector3(x, 0, y), TILE_BLOCK)

func is_cell_empty(coords):
	var data = tilemap.get_cell_item(coords)
	return data

func is_valid_spawnpoint(coords: Vector3i) -> bool:
	var data = tilemap.get_cell_item(coords)
	if data == TILE_BLOCK: # Check if the cell is a block (not a valid spawn point)
		return false
	# Add any additional conditions here to check for valid spawn points
	return true


func is_spawnpoint_taken(coords: Vector3i) -> bool:
	for orb in orb_spawner.get_children():
		if tilemap.local_to_map(orb.global_position) == coords:
			return true
	return false

func generate_inner():
	rng.randomize()
	var spawn_zones = [
		[Vector3i(1, 0, 1), Vector3i(1, 0, 2), Vector3i(1,0, 3 )],
		[Vector3i(map_width - 2, 0, 1), Vector3i(map_width - 2, 0, 2), Vector3i(map_width - 2, 0, 3)],
		[Vector3i(1, 0, map_height - 2), Vector3i(1, 0, map_height - 3), Vector3i(1, 0, map_height - 4)],
		[Vector3i(map_width - 2, 0, map_height - 2), Vector3i(map_width - 2, 0, map_height - 3), Vector3i(map_width - 2, 0, map_height - 4)]
	]
	for x in range(1, map_width - 1):
		for y in range(1, map_height - 1):
			var base_breakable_chance = 0.2
			var level_chance_multiplier = 0.001
			var breakable_spawn_chance = base_breakable_chance + (level - 1) * level_chance_multiplier
			breakable_spawn_chance = min(breakable_spawn_chance, 0.5)
			var current_cell = Vector3i(x, 0, y)
			var skip_current_cell = false
			if x % 2 == 0 and y % 2 == 0:
				skip_current_cell = true
			for corner in spawn_zones:
				if current_cell in corner:
					skip_current_cell = true
					break
			if skip_current_cell:
				continue
			if is_cell_empty(current_cell):
				if rng.randf() < breakable_spawn_chance:
					tilemap.set_cell_item(Vector3(x, 0, y), TILE_BLOCK)

func generate_orbs(instance_count = 1) -> Array:
	var spawn_points : Array = []
	for x in range(1, map_width - 1):
		for y in range(1, map_height - 1):
			spawn_points.append(Vector3i(x, 0, y))
	var orbs_in_level = []
	for i in range(instance_count):
		var attempts = 0
		var spawned = false
		while attempts < spawn_points.size() and not spawned:
			var random_index = rng.randi_range(0, spawn_points.size() - 1)
			var spawn_coords = spawn_points[random_index]
			if is_valid_spawnpoint(spawn_coords) and not is_spawnpoint_taken(spawn_coords):
				var content_orb : Orb = orb_scene.instantiate()
				content_orb.global_position = tilemap.map_to_local(spawn_coords)
				orb_spawner.add_child(content_orb)
				orbs_in_level.append(content_orb)
				spawned = true
			else:
				spawn_points.erase(random_index)
				attempts += 1
	return orbs_in_level

#func generate_orbs(instance_count = 1) -> Array:
	#var spawn_points : Array = []
	#for x in range(1, map_width - 1):
		#for y in range(1, map_height - 1):
			#spawn_points.append(Vector3i(x, 0, y))
	#print(spawn_points)
	#var orbs_in_level = []
	#for i in range(instance_count):
		#var attempts = 0
		#var spawned = false
		#while attempts < spawn_points.size() and not spawned:
			#var random_index = rng.randi_range(0, spawn_points.size() - 1)
			#var spawn_coords = spawn_points[random_index]
			#if is_valid_spawnpoint(spawn_coords) and not is_spawnpoint_taken(spawn_coords):
				#var content_orb : Orb = orb_scene.instantiate()
				#content_orb.global_position = tilemap.map_to_local(spawn_coords)
				#orb_spawner.add_child(content_orb)
				#orbs_in_level.append(content_orb)
				#spawned = true
			#else:
				#spawn_points.erase(random_index)
				#attempts += 1
	#return orbs_in_level
