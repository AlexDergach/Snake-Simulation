extends Control

var toggle = true
var mouse = 1
var full = false

@onready var max_speed_slider = $Sliders/HSlider
@onready var snake_length_slider = $Sliders/HSlider2
@onready var slither_radiu_slider = $Sliders/HSlider3
@onready var slither_amp_slider = $Sliders/HSlider4
@onready var seek_radius_slider = $Sliders/HSlider5

# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
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
	pass
