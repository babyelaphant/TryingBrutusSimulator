extends CharacterBody3D

@export var speed: float = 2.0
@export var path_parent: Node3D

var start_dialogue: Array = [
	"hello, mister goat",
	"where is the diet coke at gangy?",
	"i been trynna find it",
]

var has_drink_dialog: Array = [
	"thanks for the drink",
]

signal custom_signal

var current_dialog = 0
var waypoints: Array = []
var current_target_index: int = 0
var is_waiting: bool = false
var is_walking: bool = false
var dynamic_label := Label.new()
var has_drink = false
var customer_in_store = false
var customer_is_done = false
@onready var player: CharacterBody3D = $"../Player"

enum State {
	WALKING,
	BROWSING,
	WALKING_TO_REGISTER,
	AT_REGISTER,
	WAITING,
	ORDERING,
	THANKS,
	LEAVING
}

var current_state: State = State.WALKING

func _ready():
	randomize() 
	print(player)
	for child in get_parent().get_children():
		if child.name == "customer_path":
			for c in child.get_children():
				waypoints.append(c.position)

func _physics_process(delta):

	if global_position.distance_to( waypoints[5]) < 0.8 and current_target_index == 5 and current_state != State.WAITING and current_state != State.LEAVING and current_state != State.ORDERING and current_state != State.THANKS:
		current_state = State.AT_REGISTER
	
	match current_state:
		State.WALKING:
			is_walking = true
			walking()
		State.BROWSING:
			rest_at_waypoint()
		State.WALKING_TO_REGISTER:
			walk_to_register()
		State.AT_REGISTER:
			current_state = State.ORDERING
		State.WAITING:
			if Input.is_action_just_pressed("skip_dialog") and player.has_drink:
				has_drink = true
				current_state = State.THANKS
		State.ORDERING:
			print("ordering")
			Dialogic.start("Day_one_customer_ordering")
			current_state = State.WAITING
		State.THANKS:
			Dialogic.start("Day_one_customer_thanks")
			current_state = State.LEAVING
		State.LEAVING:
			leave_store()

func leave_store():
	if Dialogic.current_timeline == null:
		var direction = global_position.direction_to(Vector3.ZERO)
		velocity = direction * speed
		move_and_slide()
	
	if (position - waypoints[0]).length() > 20.0:
		customer_is_done = true

func walk_to_register():
	
	is_waiting = true
	current_target_index = 5
	
	var target_pos = waypoints[current_target_index]
	
	var direction = global_position.direction_to(target_pos)
	velocity = direction * speed
	move_and_slide()
	
	if global_position.distance_to(target_pos) < 0.8:
		print("sup")
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
		
		#if randf() < percent:
			#get_prev_point()
		#else:
		get_next_point()
			
		if randf() < 0.5:
			current_state = State.BROWSING

func rest_at_waypoint():
	is_waiting = true
	velocity = Vector3.ZERO
	
	await get_tree().create_timer(2.0).timeout
	is_waiting = false
	
	if current_state != State.WALKING_TO_REGISTER:
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


func _on_entrance_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	if body.is_in_group("customer"):
		customer_in_store = !customer_in_store
		
