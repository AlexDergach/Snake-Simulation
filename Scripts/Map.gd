extends Node3D


var ui_instance
var ui_scene = load("res://Scene/UI.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	
	ui_instance = ui_scene.instantiate()
	add_child(ui_instance)
	
	pass # Replace with function body.


func _process(delta):

	if Input.is_action_just_pressed("Esc"):
		get_tree().quit()

