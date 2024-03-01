class_name Player extends CharacterBody3D

@export var speed: float = 5.0
@export var jump_velocity: float = 4.5
@export var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@export var mouse_sensitivity: float = 0.001
@export var camera: Camera3D

var look_dir: Vector2

signal interacted

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(delta):
	handle_movement(delta)


func _unhandled_input(event):
	handle_camera_rotation(event)
	
	if (Input.is_action_just_pressed("interact")):
		interacted.emit()


func handle_movement(delta):
	var _velocity: Vector3 = velocity
	if (!is_on_floor()):
		_velocity.y -= gravity * delta
		
	if (Input.is_action_just_pressed("jump") and is_on_floor()):
		_velocity.y = jump_velocity
	
	var input_direction = (Input.get_vector("left", "right", "up", "down"))
	var direction = (transform.basis * Vector3(input_direction.x, 0, input_direction.y)).normalized()
	
	if (direction != Vector3.ZERO):
		_velocity.x = direction.x * speed
		_velocity.z = direction.z * speed
	else:
		_velocity.x = move_toward(velocity.x, 0, speed)
		_velocity.z = move_toward(velocity.z, 0, speed)

	velocity = _velocity
	move_and_slide()
	

func handle_camera_rotation(event):
	var mouse_motion: InputEventMouseMotion
	if (event is InputEventMouseMotion):
		mouse_motion = event
		rotate_y(-mouse_motion.relative.x * mouse_sensitivity)
		camera.rotate_x(-mouse_motion.relative.y * mouse_sensitivity)
		camera.rotation = Vector3(clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90)), camera.rotation.y, camera.rotation.z)
		
		
