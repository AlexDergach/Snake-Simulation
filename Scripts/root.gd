extends Node3D

func _ready():
	pass


func _process(delta):
	
	if Input.is_action_just_pressed("Esc"):
		get_tree().quit()
	
	pass
