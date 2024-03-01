extends RayCast3D

@onready var player: Player = get_parent().get_parent()


func _process(delta):
	handle_ray_collision()


func handle_ray_collision():
	if (is_colliding()):
		var hit_obj: Node = get_collider()
		if hit_obj == null: 
			return
		print(hit_obj.name)
		#if (hit_obj is Orb):
			## todo: add Orb interation
			#pass 
