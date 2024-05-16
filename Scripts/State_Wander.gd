class_name State_Wander extends State

var snake
var random_loc
var field_of_view_angle = PI / 4
@export var radius : float = 25

var collision_lock = false
@onready var timer = get_node("../Timer")

var first_point_delay = 0

var prey
var prey_list = []


func _ready():
	snake = get_parent()
	

func _enter():
	snake.get_node("Behaviour_Seek").set_enabled(true)
	snake.get_node("Behaviour_Avoidance").set_enabled(true)
	snake.get_node("Behaviour_Harmonic").set_enabled(true)
	
	for prey in get_tree().get_nodes_in_group("mouse"):
		prey_list.append(prey)
		
	timer.start(10)
	
	
	
	

func _exit():
	snake.get_node("Behaviour_Seek").set_enabled(false)
	snake.get_node("Behaviour_Harmonic").set_enabled(false)
	snake.get_node("Behaviour_Avoidance").set_enabled(false)
	
	

func _think():
	# small delay for put_on_ground function's raycast to work
	if first_point_delay == 10:
		# detect prey
		if !prey:
			detect_prey()
		else:
			var AttackState = load("res://AttackState.gd")
			snake.get_node("StateMachine").change_state(AttackState.new())
		
		if random_loc == null:
			random_loc = get_random_point_in_radius()
		else:
			snake.get_node("Behaviour_Seek").world_target = random_loc
			
			if snake.get_node("Behaviour_Avoidance").calculate().length() > snake.get_node("Behaviour_Seek").calculate().length()/2:
				var avoidance_force = snake.get_node("Behaviour_Avoidance").calculate()
				var opposite_direction = -avoidance_force.normalized()
				random_loc = snake.global_position + -opposite_direction * radius/2
				random_loc = put_on_ground(random_loc)
				snake.get_node("Behaviour_Seek").world_target = random_loc
				collision_lock = true
			
			if random_loc.distance_to(snake.global_position) < 3:
				random_loc = null
				collision_lock = false
				timer.stop()
				timer.start()
				
	else:
		first_point_delay += 1
	

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

	var targetloc = snake.global_position + Vector3(x, 0, z)
	
	var pos_on_ground = put_on_ground(targetloc)
	
	return pos_on_ground

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

func detect_prey():
	for p in prey_list:
		if p.global_position.distance_to(snake.global_position) < 5:
			prey = p
			break

func _on_timer_timeout():
	random_loc = null
	collision_lock = false
	timer.start()

