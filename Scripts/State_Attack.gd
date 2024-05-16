class_name State_Attack extends State

var snake
var random_loc
var field_of_view_angle = PI / 4
@export var radius : float = 25

var collision_lock = false
@onready var timer = get_node("../Timer")

var first_point_delay = 0
var prey

func _ready():
	snake = get_parent()
	

func _enter():
	snake.get_node("Behaviour_Seek").set_enabled(true)
	snake.get_node("Behaviour_Avoidance").set_enabled(true)
	snake.get_node("Behaviour_Harmonic").set_enabled(true)
		
	timer.start(10)
	
	print("attack state entered")
	
	

func _exit():
	snake.get_node("Behaviour_Seek").set_enabled(false)
	snake.get_node("Behaviour_Harmonic").set_enabled(false)
	snake.get_node("Behaviour_Avoidance").set_enabled(false)
	
	

func _think():
	pass
	

func put_on_ground(loc):
	var raycast = RayCast3D.new()
	raycast.target_position = Vector3(0, -25, 0)  # Set the length and direction of the ray
	raycast.global_position = loc + Vector3(0, 15, 0)
	
	add_child(raycast)
	
	raycast.force_raycast_update()
	
	if raycast.is_colliding():
		loc.y = raycast.get_collision_point().y
	
	print(raycast.get_collision_point())
	print(loc)
	
	remove_child(raycast)
	raycast.queue_free()
	
	return loc

func _on_timer_timeout():
	random_loc = null
	collision_lock = false
	timer.start()

