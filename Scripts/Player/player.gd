extends CharacterBody3D

const SPEED = 5.0


@export var mouse_sensitivity: float = 0.002
@export var hold_distance: float = 2.0


@onready var camera_3d: Camera3D = $Camera3D
@onready var ray_cast_3d: RayCast3D = $Camera3D/RayCast3D

var vertical_rotation: float = 0.0
var held_object: Node3D = null


var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	ray_cast_3d.enabled = false  # Disabled by default to save performance

func _unhandled_input(event: InputEvent) -> void:
	
	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			
	
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		vertical_rotation -= event.relative.y * mouse_sensitivity
		vertical_rotation = clamp(vertical_rotation, deg_to_rad(-85.0), deg_to_rad(85.0))
		camera_3d.rotation.x = vertical_rotation

func _physics_process(delta: float) -> void:
	# Add the gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	
	if Input.is_action_pressed("interact"):
		print("son")
		handle_interact()

	
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
	
	if held_object != null:
		held_object.global_transform.origin = camera_3d.global_transform.origin - camera_3d.global_transform.basis.z * hold_distance

func handle_interact() -> void:
	# If already holding an object, drop it
	if held_object != null:
		if held_object.has_method("drop"):
			print("dropping")
			held_object.drop()
			held_object = null
			return

	ray_cast_3d.enabled = true
	ray_cast_3d.force_raycast_update()
	
	if not ray_cast_3d.is_colliding():
		ray_cast_3d.enabled = false
		return
		
	var target = ray_cast_3d.get_collider()
	
	if target and target.has_method("pick_up"):
		print("picking up")
		held_object = target
		target.pick_up()
		
	ray_cast_3d.enabled = false
