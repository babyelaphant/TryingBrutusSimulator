extends StaticBody3D

@export var item_id: int = 1
@export var is_full: bool = true

@onready var label := $Label3D
@onready var item_spawn := $item_spawn

var item_instance: Node3D = null

func _ready() -> void:
	load_item_mesh()
	update_shelf()

func load_item_mesh() -> void:

	if item_instance:
		item_instance.queue_free()
		item_instance = null
	
	var path = "res://Models/Interactables/aisle_items_" + str(item_id) + ".glb"
	
	var packed = load(path)
	item_instance = packed.instantiate()
	item_spawn.add_child(item_instance)
	
func update_shelf() -> void:
	if item_instance:
		item_instance.visible = is_full
	
	label.visible = not is_full
	label.text = "Empty"
	
func restock() -> void:
	is_full = true
	update_shelf()
func empty_shelf() -> void:
	is_full = false
	update_shelf() 
	
