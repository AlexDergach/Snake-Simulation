class_name State_Wander extends State

var snake
var prey
var random_loc
var field_of_view_angle = PI / 2  # 45 degrees on each side of the forward direction
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
		if random_loc.distance_to(snake.global_position) < 2:
			random_loc = null
			

func get_random_point_in_radius():
	#var angle = randf() * PI * 2
	#var x = cos(angle) * radius
	#var z = sin(angle) * radius
	#return Vector3(x, 0, z)
	
	var half_fov = field_of_view_angle / 2
	var random_angle = randf_range(-half_fov, half_fov)
	
	var forward_direction = snake.transform.basis.z.normalized()
	var rotation = Quaternion(Vector3.UP, random_angle)
	var direction = rotation*forward_direction
	
	var x = direction.x * radius * randf()
	var z = direction.z * radius * randf()

	return snake.global_transform.origin + Vector3(x, 0, z)
