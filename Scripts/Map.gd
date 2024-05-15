extends Node3D

const MOUSE = preload("res://Scene/Mouse.tscn")
var mouse_instance
var spawn_amount = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if spawn_amount > 0:
		mouse_instance = MOUSE.instantiate()
		add_child(mouse_instance)
		spawn_amount -= 1
		
		mouse_instance.position.x = randf_range(10,-10)
		mouse_instance.position.z = randf_range(10,-10)
		mouse_instance.position.y = 1
	
	if Input.is_action_just_pressed("Esc"):
		get_tree().quit()
	pass
