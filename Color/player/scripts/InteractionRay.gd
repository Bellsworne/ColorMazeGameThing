extends RayCast3D

@onready var player: Player = get_parent().get_parent()


func _process(_delta : float) -> void:
	handle_ray_collision()


func handle_ray_collision():
	if (is_colliding()):
		var hit_obj: Node = get_collider()

		if hit_obj == null:
			return
		if (hit_obj is Orb):
			if Input.is_action_just_released("interact"):
				player.orbintory.collection.append(hit_obj)
				hit_obj._goto_hell()
