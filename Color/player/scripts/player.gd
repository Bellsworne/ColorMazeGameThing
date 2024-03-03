class_name Player extends CharacterBody3D

@export var speed: float = 5.0
@export var sprint_speed_modifier: float = 5.0
@export var jump_velocity: float = 4.5
@export var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@export var mouse_sensitivity: float = 0.001
@export var camera: Camera3D
@export var max_health: int = 100
@export var current_health: int = max_health
@export var max_stamina: int = 100
@export var current_stamina: int = max_stamina
@export var remaining_lives: int = 3

var is_sprinting: bool = false
var can_sprint: bool = true

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
	handle_sprinting()
	move_and_slide()


func handle_sprinting():
	if (is_sprinting and current_stamina > 0):
		get_tree().create_timer(0.5).timeout
		current_stamina -= 1
	elif (!is_sprinting and current_stamina < max_stamina):
		get_tree().create_timer(0.5).timeout
		current_stamina += 1
	
	if (current_stamina <= 1 or !is_on_floor()):
		can_sprint = false
		is_sprinting = false
	elif (current_stamina >= 1 and is_on_floor()):
		can_sprint = true
	
	if (Input.is_action_just_pressed("sprint") and can_sprint):
		is_sprinting = true
	elif (Input.is_action_just_released("sprint")):
		is_sprinting = false
			
	clampf(current_stamina, 0, max_stamina)


func handle_camera_rotation(event : InputEvent) -> void:
	var mouse_motion: InputEventMouseMotion
	if (event is InputEventMouseMotion):
		mouse_motion = event
		rotate_y(-mouse_motion.relative.x * mouse_sensitivity)
		camera.rotate_x(-mouse_motion.relative.y * mouse_sensitivity)
		camera.rotation = Vector3(clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90)), camera.rotation.y, camera.rotation.z)
