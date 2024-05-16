class_name Mouse extends CharacterBody3D

@export var mass = 1
@export var acceleration = Vector3.ZERO
@export var force = Vector3.ZERO
@export var speed = 1.0
@export var max_speed: float = 2.0
@export var vel = Vector3.ZERO

var behaviors = [] 
@export var max_force = 10
@export var draw_gizmos = true

var new_force = Vector3.ZERO
var should_calculate = false
@export var damping = 0

var random_loc
var field_of_view_angle = PI / 4
var radius = 10
var collision_lock = true
@onready var timer = get_node("Timer")

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	timer.start(10)
	
	for i in get_child_count():
		var child = get_child(i)
		if child.has_method("calculate"):
			behaviors.push_back(child)
			child.set_process(child.enabled) 

func _process(delta):
	should_calculate = true
	if draw_gizmos:
		on_draw_gizmos()
	

func _physics_process(delta):
	
	if random_loc == null:
		random_loc = get_random_point_in_radius()
	else:
		get_node("Behaviour_Seek").world_target = random_loc
		
		if get_node("Behaviour_Avoidance").calculate().length() > get_node("Behaviour_Seek").calculate().length():
			var avoidance_force = get_node("Behaviour_Avoidance").calculate()
			var opposite_direction = -avoidance_force.normalized()
			random_loc = global_transform.origin + -opposite_direction * radius
			get_node("Behaviour_Seek").world_target = random_loc
			collision_lock = true
		
		if random_loc.distance_to(global_position) < 3:
			random_loc = null
			collision_lock = false
			timer.stop()
			timer.start()
	
	if should_calculate:
		new_force = calculate()

	force = lerp(force, new_force, delta*5)
	acceleration = force / mass
	vel += acceleration * delta
	speed = vel.length()
	if speed > 0:		
		if max_speed == 0:
			print("max_speed is 0")
		vel = vel.limit_length(max_speed)
		
		# damping
		vel -= vel * delta * damping
		
		set_velocity(vel)
		
		look_at(global_position - vel.normalized(),Vector3.UP)
		
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	move_and_slide()
	
func get_random_point_in_radius():
	# choose a random angle within the field of view
	var half_fov = field_of_view_angle / 3
	var random_angle = randf_range(-half_fov, half_fov)
	
	# calculate the direction vector
	var forward_direction = transform.basis.z.normalized()
	var rotation = Quaternion(Vector3.UP, random_angle)
	var direction = rotation*forward_direction
	
	# calculate the random point within the radius
	var x = direction.x * radius * randf()
	var z = direction.z * radius * randf()

	var targetloc = global_position + Vector3(x, 0, z)
	
	var raycast = RayCast3D.new()
	raycast.target_position = Vector3(0, -25, 0)  # Set the length and direction of the ray
	raycast.global_position = targetloc + Vector3(0, 15, 0)
	
	add_child(raycast)
	raycast.force_raycast_update()
	
	if raycast.is_colliding():
		targetloc.y = raycast.get_collision_point().y
	
	remove_child(raycast)
	raycast.queue_free()
	
	return targetloc

func seek_force(target: Vector3):	
	var toTarget = target - global_transform.origin
	toTarget = toTarget.normalized()
	var desired = toTarget * max_speed
	return desired - vel

func update_weights(weights):
	for behavior in weights:
		var b = get_node(behavior)
		if b: 
			b.weight = weights[behavior]

func calculate():
	var force_acc = Vector3.ZERO	
	var behaviors_active = ""
	for i in behaviors.size():
		if behaviors[i].enabled:
			var f = behaviors[i].calculate() * behaviors[i].weight
			if is_nan(f.x) or is_nan(f.y) or is_nan(f.z):
				print(str(behaviors[i]) + " is NAN")
				f = Vector3.ZERO
			behaviors_active += behaviors[i].name + ": " + str(round(f.length())) + " "
			force_acc += f 
			if force_acc.length() > max_force:
				force_acc = force_acc.limit_length(max_force)
				behaviors_active += " Limiting force"
				break
	if draw_gizmos:
		DebugDraw2D.set_text(name, behaviors_active)
	return force_acc

func on_draw_gizmos():
	DebugDraw3D.draw_arrow(global_position,  global_transform.origin + transform.basis.z * 2.0 , Color(0, 0, 1), 0.1)
	DebugDraw3D.draw_arrow(global_position,  global_transform.origin + transform.basis.x * 2.0 , Color(1, 0, 0), 0.1)
	DebugDraw3D.draw_arrow(global_position,  global_transform.origin + transform.basis.y * 2.0 , Color(0, 1, 0), 0.1)
	DebugDraw3D.draw_arrow(global_position,  global_transform.origin + force, Color(1, 1, 0), 0.1)
	

func _on_timer_timeout():
	random_loc = null
	collision_lock = false
	timer.start()
