class_name StateMachine extends Node

@export var initial_state:NodePath

var current_state:State
var previous_state:State

var snake

func change_state(new_state):
	print(str(snake) + "\t" + new_state.get_class())
	if current_state:
		current_state._exit()
		snake.call_deferred("remove_child", current_state);
	current_state = new_state
	if current_state:
		snake.add_child(current_state);
		current_state._enter()
	
func _ready():
	snake = get_parent()
	if initial_state:
		current_state = get_node(initial_state)
		current_state.call_deferred("_enter")

func _process(delta):
	#DebugDraw2D.set_text(get_parent().get_script().resource_path.get_file(), current_state.get_script().resource_path.get_file() + " ")
	
	if current_state:
		current_state._think()
