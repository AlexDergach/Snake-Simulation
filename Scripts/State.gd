class_name State extends Node

var state_machine

func _enter():
	pass

func _exit():
	pass
	
func _think():
	pass
 
func _ready():
	state_machine = get_parent()
