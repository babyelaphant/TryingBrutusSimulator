extends RigidBody3D

var is_held := false

func pick_up() -> void:
	is_held = true
	freeze = true
	$CollisionShape3D.disabled = true

func drop() -> void:
	is_held = false
	freeze = false
	$CollisionShape3D.disabled = false
 
