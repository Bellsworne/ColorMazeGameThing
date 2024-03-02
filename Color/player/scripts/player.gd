class_name Player extends CharacterBody3D

@export var speed: float = 5.0
@export var sprint_speed_modifier: float = 5.0
@export var jump_velocity: float = 4.5
@export var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@export var mouse_sensitivity: float = 0.001
@export var camera: Camera3D

var max_health: int = 100
var current_health: int = max_health
var max_stamina: float = 100
var current_stamina: float = max_stamina
var remaining_lives: int = 3

var is_sprinting: bool = false

var orbintory : Orbintory = Orbintory.new()
var look_dir: Vector2

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(delta) -> void:
	handle_movement(delta)


func _unhandled_input(event : InputEvent) -> void:
	handle_camera_rotation(event)
	
	if (event.is_action_pressed("pause")):
		if (Input.mouse_mode == Input.MOUSE_MODE_CAPTURED):
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		
func handle_movement(delta) -> void:
	is_sprinting = Input.is_action_pressed("sprint")
	
	var _velocity: Vector3 = velocity
	if (!is_on_floor()):
		_velocity.y -= gravity * delta
		
	if (Input.is_action_just_pressed("jump") and is_on_floor()):
		_velocity.y = jump_velocity
		
	
	var input_direction = (Input.get_vector("left", "right", "up", "down"))
	var direction = (transform.basis * Vector3(input_direction.x, 0, input_direction.y)).normalized()
	
	if (direction != Vector3.ZERO):
		if (is_sprinting):
			_velocity.x = direction.x * (speed + sprint_speed_modifier)
			_velocity.z = direction.z * (speed + sprint_speed_modifier)
		else:
			_velocity.x = direction.x * speed
			_velocity.z = direction.z * speed
	else:
		_velocity.x = move_toward(velocity.x, 0, speed)
		_velocity.z = move_toward(velocity.z, 0, speed)

	velocity = _velocity
	move_and_slide()


func handle_camera_rotation(event : InputEvent) -> void:
	var mouse_motion: InputEventMouseMotion
	if (event is InputEventMouseMotion):
		mouse_motion = event
		rotate_y(-mouse_motion.relative.x * mouse_sensitivity)
		camera.rotate_x(-mouse_motion.relative.y * mouse_sensitivity)
		camera.rotation = Vector3(clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90)), camera.rotation.y, camera.rotation.z)
