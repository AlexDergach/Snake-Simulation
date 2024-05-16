extends Control

var toggle = true
var mouse = 1
var full = false

@onready var label_6 = $Sliders/Label6
@onready var label_7 = $Sliders/Label7
@onready var label_8 = $Sliders/Label8
@onready var label_9 = $Sliders/Label9
@onready var label_10 = $Sliders/Label10

@onready var current_state = $Info/Label2

@onready var snake = $"../snake"
@onready var snakeHead = $"../snake/entity/snakeHead"

var toggle_gizmos = false

func _ready():
	pass 

func _process(delta):
	
	current_state.text = snake.get_node("entity/snakeHead/StateMachine").current_state.get_state()
	
	if Input.is_action_just_pressed("F"):
		if full:
			full = false
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			full = true
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
	
	if Input.is_action_just_pressed("Vis"):
		toggle = !toggle
		self.visible = toggle
	
	if Input.is_action_just_pressed("Mouse"):
		if mouse == 1:
			mouse_filter = MOUSE_FILTER_STOP
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			mouse = 0
		else:
			mouse_filter = MOUSE_FILTER_PASS
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
			mouse = 1


func _on_h_slider_value_changed(value):
	label_6.text = str(value)
	snake.max_speed = value

func _on_h_slider_3_value_changed(value):
	label_8.text = str(value)
	snake.slither_radius = value

func _on_h_slider_4_value_changed(value):
	label_9.text = str(value)
	snake.slither_amplitude = value

func _on_h_slider_5_value_changed(value):
	label_10.text = str(value)
	snake.seek_radius = value

func _on_button_pressed():
	if toggle_gizmos:
		snakeHead.get_node("Behaviour_Avoidance").draw_gizmos = false
		snakeHead.get_node("Behaviour_Harmonic").draw_gizmos = false
		snakeHead.get_node("Behaviour_Seek").draw_gizmos = false
		snakeHead.draw_gizmos = false
		
		toggle_gizmos = false
	else:
		snakeHead.get_node("Behaviour_Avoidance").draw_gizmos = true
		snakeHead.get_node("Behaviour_Harmonic").draw_gizmos = true
		snakeHead.get_node("Behaviour_Seek").draw_gizmos = true
		snakeHead.draw_gizmos = true
		
		toggle_gizmos = true
