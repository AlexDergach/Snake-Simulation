class_name State_Wander extends State

var snake
var prey
var random_loc
var field_of_view_angle = PI / 2
@export var radius : float = 10

func _ready():
	snake = get_parent()

func _enter():
	snake.get_node("Behaviour_Seek").set_enabled(true)
	snake.get_node("Behaviour_Avoidance").set_enabled(true)
	
	random_loc = get_random_point_in_radius()
	snake.get_node("Behaviour_Seek").world_target = random_loc

func _exit():
	snake.get_node("Behaviour_Seek").set_enabled(false)

func _think():
	#if prey.distance_to(snake.global_transform.origin) < 5:
		#var AttackState = load("res://AttackState.gd")
		#snake.get_node("StateMachine").change_state(AttackState.new())
		
	if random_loc == null:
		random_loc = get_random_point_in_radius()
	else:
		snake.get_node("Behaviour_Seek").world_target = random_loc
		
		if snake.get_node("Behaviour_Avoidance").calculate().length() > snake.get_node("Behaviour_Seek").calculate().length()*1.5:
			print(snake.get_node("Behaviour_Avoidance").calculate().length())
			print("wait")
			print("wait")
			print("wait")
		
		if random_loc.distance_to(snake.global_position) < 2:
			random_loc = null
			

func get_random_point_in_radius():
	# choose a random angle within the field of view
	var half_fov = field_of_view_angle / 2
	var random_angle = randf_range(-half_fov, half_fov)
	
	# calculate the direction vector
	var forward_direction = snake.transform.basis.z.normalized()
	var rotation = Quaternion(Vector3.UP, random_angle)
	var direction = rotation*forward_direction
	
	# calculate the random point within the radius
	var x = direction.x * radius * randf()
	var z = direction.z * radius * randf()

	return snake.global_position + Vector3(x, 0, z)
