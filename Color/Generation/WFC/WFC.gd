extends Node3D
class_name MazeGenerator

@onready var orb_spawner : Node3D = get_parent().get_node("OrbSpawner")

const orb_scene = preload("res://Content/Orb/Orb.tscn")
@export var tilemap : GridMap
@export var level : int = 12
@export var map_width : int = 8 * level
@export var map_height : int = 8 * level

const TILE_BLOCK = 0

var rng : RandomNumberGenerator = RandomNumberGenerator.new()

func _ready():
	generate()

var orbs : Array # GENERAL
var orbs_found : Array = [] # FOR DFS
var visited_cells : Array = [] # FOR DFS TOO
func generate():
	generate_border()
	generate_inner()
	generate_orbs()
	orbs = generate_orbs(level * 2)
	delete_barriers_between_orbs_recursive()
func generate_border() -> void:
	for x in range(map_width):
		for y in range(map_height):
			if x == 0 or x == map_width - 1 or y == 0 or y == map_height - 1:
				tilemap.set_cell_item(Vector3(x, 0, y), TILE_BLOCK)
	for x in range(1, map_width - 2):
		for y in range(1, map_height - 2):
			if x % 2 == 0 and y % 2 == 0:
				tilemap.set_cell_item(Vector3(x, 0, y), TILE_BLOCK)

func is_valid_move(coords : Vector3i) -> bool:
	if coords.x < 0 or coords.x >= map_width or coords.z < 0 or coords.z >= map_height:
		return false
	var cell_contents = tilemap.get_cell_item(coords)
	if cell_contents == TILE_BLOCK: return false
	for orb in orbs:
		if Vector3i(tilemap.map_to_local(orb.global_position)) == coords: return false
	return true
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

func is_cell_empty(coords):
	var data = tilemap.get_cell_item(coords)
	return data == -1 
func is_valid_spawnpoint(coords: Vector3i) -> bool:
	var data = tilemap.get_cell_item(coords)
	return data != TILE_BLOCK  
func is_spawnpoint_taken(coords: Vector3i) -> bool:
	for orb in orb_spawner.get_children():
		var orb_coords = tilemap.map_to_local(orb.global_position)
		if Vector3i(orb_coords) == coords:
			return true
	return false

func is_accessible(coords: Vector3i) -> bool:
	var data = tilemap.get_cell_item(coords)
	return data != TILE_BLOCK  

	
### COMMENT ALL OF THIS OUT IF YOU WANT GAME NOT TO CRASH FROM INFINITE RECURSION
func delete_barriers_between_orbs_recursive(index: int = 0):
	if index >= len(orbs):
		return  
	for j in range(index + 1, len(orbs)):
		var start_coords = tilemap.local_to_map(orbs[index].global_position)
		var target_coords = tilemap.local_to_map(orbs[j].global_position)
		var barrier_coords = find_wall_between_cells(start_coords, target_coords)
		
		if barrier_coords != Vector3i(-1, -1, -1):
			tilemap.set_cell_item(barrier_coords, 2)
	
	delete_barriers_between_orbs_recursive(index + 1)

func find_wall_between_cells(start_coords: Vector3i, target_coords: Vector3i, step: Vector3i = Vector3i.ZERO) -> Vector3i:
	var dx = abs(target_coords.x - start_coords.x)
	var dz = abs(target_coords.z - start_coords.z)
	
	var wall_coords = start_coords + step
	
	if wall_coords == target_coords:
		return Vector3i(-1, -1, -1) 
	if tilemap.get_cell_item(wall_coords) == TILE_BLOCK:
		return wall_coords
	
	if dx != 0 and dz == 0:
		var wall_x = (start_coords.x + target_coords.x) / 2
		var wall_z = start_coords.z
		return find_wall_between_cells(start_coords, target_coords, Vector3i(wall_x, 0, wall_z) - start_coords)
	elif dx == 0 and dz != 0:
		var wall_x = start_coords.x
		var wall_z = (start_coords.z + target_coords.z) / 2
		return find_wall_between_cells(start_coords, target_coords, Vector3i(wall_x, 0, wall_z) - start_coords)
	
	return Vector3i(-1, -1, -1)
