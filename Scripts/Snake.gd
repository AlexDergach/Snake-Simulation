class_name Snake extends CharacterBody3D

@export var mass = 1
@export var acceleration = Vector3.ZERO
@export var force = Vector3.ZERO
@export var speed = 2.0
@export var max_speed: float = 3.0
@export var vel = Vector3.ZERO

var behaviors = [] 
@export var max_force = 10
@export var draw_gizmos = true

var new_force = Vector3.ZERO
var should_calculate = false
@export var damping = 0.1

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():	
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
	
	if should_calculate:
		new_force = calculate()

	force = lerp(force, new_force, delta)
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
		
		# banking
		var temp_up = global_transform.basis.y.lerp(Vector3.UP + acceleration/2, delta/2)
		look_at(global_position - vel.normalized(),temp_up)
		
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	move_and_slide()
	

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
	
