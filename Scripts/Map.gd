extends Node3D


func _ready():
	pass # Replace with function body.


func _process(delta):

	if Input.is_action_just_pressed("Esc"):
		get_tree().quit()

