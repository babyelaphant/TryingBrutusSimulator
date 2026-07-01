extends CharacterBody3D

const SPEED = 5.0


@export var mouse_sensitivity: float = 0.002
@export var hold_distance: float = 2.0


@onready var camera_3d: Camera3D = $Camera3D
@onready var ray_cast_3d: RayCast3D = $Camera3D/RayCast3D

var vertical_rotation: float = 0.0
var held_object: Node3D = null
var is_in_dialog = false
var has_drink = false
var interactable_label = Label.new()
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var in_drink_zone = false

func _ready() -> void:
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	ray_cast_3d.enabled = false  # Disabled by default to save performance

func _unhandled_input(event: InputEvent) -> void:
	
	if is_in_dialog:
		return
	
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
	
	if in_drink_zone and Input.is_action_pressed("hold_interact"):
		has_drink = true
	
	if is_in_dialog:
		fix_camera()
		return

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

func fix_camera():
	
	pass
	#rotation.y = 90

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


func _on_drinks_body_entered(body: Node3D) -> void:
	
	if body.is_in_group("player"):
		add_child(interactable_label)
		interactable_label.position = Vector2(500,550)
		interactable_label.text = "drinks"
		interactable_label.visible = true
		in_drink_zone = true


func _on_drinks_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		interactable_label.visible = false
		in_drink_zone = false
