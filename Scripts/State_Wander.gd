class_name State_Wander extends State

var snake
var prey
var random_loc
var field_of_view_angle = PI / 5
@export var radius : float = 25

var collision_lock = false
@onready var timer = get_node("../Timer")

var first_point_delay = 0


func _ready():
	snake = get_parent()

func _enter():
	snake.get_node("Behaviour_Seek").set_enabled(true)
	snake.get_node("Behaviour_Avoidance").set_enabled(true)
	snake.get_node("Behaviour_Harmonic").set_enabled(true)
	
	#random_loc = get_random_point_in_radius()
	#snake.get_node("Behaviour_Seek").world_target = random_loc
	
	timer.start(10)
	

func _exit():
	snake.get_node("Behaviour_Seek").set_enabled(false)
	snake.get_node("Behaviour_Harmonic").set_enabled(false)
	snake.get_node("Behaviour_Avoidance").set_enabled(false)

func _think():
	#if prey.distance_to(snake.global_transform.origin) < 5:
		#var AttackState = load("res://AttackState.gd")
		#snake.get_node("StateMachine").change_state(AttackState.new())
		
	# small delay for put_on_ground function to work
	if first_point_delay == 10:
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
	var half_fov = field_of_view_angle / 3
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

func _on_timer_timeout():
	random_loc = null
	collision_lock = false
	timer.start()
