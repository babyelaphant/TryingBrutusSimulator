extends Node3D

@onready var game = self
@onready var shelves: Node3D = $shelfs
@onready var lights: Node3D = $gas_station_lights
var customer_instance = null

const customer_scene = preload("res://Scenes/Player/customer_npc.tscn")

var interactable_label = Label.new()

var all_shelves : Array
var all_lights : Array

# day 1 variables
var day1_dialog: Array = [
	"I should probably go ",
	"where is the diet coke at gangy?",
	"i been trynna find it",
]

var stocked_store = true
var customer1 = false
var customer2 = true
var customer3 = false
var light_zone = false
var lights_off = false
var lights_turned_back_on = false
var customer_spawned = false
var broom_zone = false
var can_pick_up_broom = false
var broom_mission = false
var current_day = 0
var coffee_zone = false
var has_broom = false

enum State {
	DAY1,
	DAY2,
	DAY3,
	DAY4,
	DAY5,
	DAY6,
}

var current_state = State.DAY1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(game)
	add_child(interactable_label)
	interactable_label.position = Vector2(500,550)
	interactable_label.visible = false
	
	all_shelves = shelves.get_children()
	all_lights = lights.get_children()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	interactables()
	
	match current_day:
		State.DAY1:
			day_one()
		State.DAY2:
			pass
		State.DAY3:
			pass
		State.DAY4:
			pass
		State.DAY5:
			pass
		State.DAY6:
			pass

func day_one():
	
	stocked_store = true
	for child in all_shelves:
		if child.is_full == false:
			stocked_store = false
	
	if !stocked_store:
		interactable_label.visible = true
		interactable_label.text = "stock the shelves gang"
		#customer is coming i should probably go back to the register
	
	if stocked_store and !customer1 and !customer_spawned:
		interactable_label.visible = true
		interactable_label.text = "stocked the shelves now get back to the register for the customer"
		await get_tree().create_timer(3.0).timeout
	
	if stocked_store and !customer1 and !customer_spawned:
		
		customer_instance = customer_scene.instantiate()
		customer_instance.position = Vector3(3.188,11.72,0.354)
		add_child(customer_instance)
		customer_spawned = true
		print("spawing firrst customer")
		interactable_label.visible = true
		interactable_label.text = "help out the customer"
	
	if customer_instance and customer_instance.customer_is_done:
		customer_instance.queue_free()
		customer_spawned = false
		customer1 = true
		
	if stocked_store and customer1 and customer2 and !lights_turned_back_on and !lights_off:
		lights_off = true
		await get_tree().create_timer(3.0).timeout
		turn_off_lights()
		#lights_off = true
	
	if stocked_store and customer1 and customer2 and lights_turned_back_on and !broom_mission:
		#another customer but spill coffee
		if broom_zone and Input.is_action_just_pressed("hold_interact"):
			print("picked up broom")
			has_broom = true
		
		if has_broom and coffee_zone and Input.is_action_just_pressed("hold_interact"):
			print("cleaned the thing")
			broom_mission = true
			
			
	
	if light_zone and lights_off:
		if Input.is_action_just_pressed("hold_interact"):
			turn_on_lights()
		

func turn_off_lights():
	print("gang")
	for l in all_lights:
		l.visible = false

func turn_on_lights():
	print("ok")
	for l in all_lights:
		l.visible = true
	
	lights_turned_back_on = true
	lights_off = false

func interactables():
	
	if lights_off and light_zone:
		interactable_label.text = "turn on lights"
		interactable_label.visible = true
	else:
		interactable_label.visible = false
	
func _on_light_on_zone_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		light_zone = true

func _on_light_on_zone_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		light_zone = false

func _on_broom_zone_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		broom_zone = true

func _on_broom_zone_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		broom_zone = false


func _on_coffee_spill_zone_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		coffee_zone = true


func _on_coffee_spill_zone_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		coffee_zone = false
