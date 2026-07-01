extends CharacterBody3D

@export var speed: float = 2.0
@export var path_parent: Node3D

var waypoints: Array = []
var current_target_index: int = 0
var is_waiting: bool = false
var is_walking: bool = false

enum State {
	WALKING,
	BROWSING,
	WALKING_TO_REGISTER,
	AT_REGISTER,
	LEAVING
}

var current_state: State = State.WALKING

func _ready():
	randomize() 
	for child in get_parent().get_children():
		if child.name == "customer_path":
			for c in child.get_children():
				print("hey")
				waypoints.append(c.position)

func _physics_process(delta):
	print(current_target_index)
	match current_state:
		State.WALKING:
			is_walking = true
			walking()
		State.BROWSING:
			rest_at_waypoint()
		State.WALKING_TO_REGISTER:
			walk_to_register()
		State.AT_REGISTER:
			#ready for some dialouge
			pass
		State.LEAVING:
			pass

func walk_to_register():
	is_waiting = true
	current_target_index = 5
	
	var target_pos = waypoints[current_target_index]
	
	var direction = global_position.direction_to(target_pos)
	velocity = direction * speed
	move_and_slide()
	
	if global_position.distance_to(target_pos) < 0.8:
		current_state = State.AT_REGISTER
	
func walking():
	
	if is_waiting or waypoints.size() == 0 or current_target_index >= waypoints.size():
		return
		
	var target_pos = waypoints[current_target_index]
	
	var direction = global_position.direction_to(target_pos)
	velocity = direction * speed
	move_and_slide()
	
	if global_position.distance_to(target_pos) < 0.8:
		
		if current_target_index == waypoints.size() - 2:
			current_state = State.WALKING_TO_REGISTER
		
		var percent = 0.25
		
		if current_target_index > 3:
			percent = 1.0
		
		if randf() < percent:
			get_prev_point()
		else:
			get_next_point()
			
		if randf() < 0.5:
			current_state = State.BROWSING

func rest_at_waypoint():
	is_waiting = true
	velocity = Vector3.ZERO
	
	await get_tree().create_timer(2.0).timeout
	is_waiting = false
	current_state = State.WALKING

func get_next_point():
	
	if current_target_index == waypoints.size() - 1:
		return

	current_target_index += 1
	if current_target_index < waypoints.size():
		is_waiting = false
	else:
		print("done")
		
func get_prev_point():
	if current_target_index == 0:
		return
	
	current_target_index -= 1
	if current_target_index > waypoints.size():
		is_waiting = false
	else:
		print("done")
