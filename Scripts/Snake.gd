class_name Snake extends CharacterBody3D

const JUMP_VELOCITY = 4.5

@export var mass = 1
@export var acceleration = Vector3.ZERO
@export var force = Vector3.ZERO
@export var speed = 5.0
@export var max_speed: float = 10.0
@export var vel = Vector3.ZERO

var behaviors = [] 
@export var max_force = 10
@export var draw_gizmos = true

var new_force = Vector3.ZERO
var should_calculate = false
@export var damping = 0.1

var sine_time : float = 0
@export var movement_amplitude : float = 1
@export var movement_frequency : float = 1

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	#var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	#var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	#if direction:
		#velocity.x = direction.x * SPEED
		#velocity.z = direction.z * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
		#velocity.z = move_toward(velocity.z, 0, SPEED)
		
	#var direction = 
	

	if should_calculate:
		new_force = calculate()
		should_calculate = false
		
	force = lerp(force, new_force, delta)
	acceleration = force / mass
	vel += acceleration * delta
	speed = vel.length()
	if speed > 0:		
		if max_speed == 0:
			print("max_speed is 0")
		vel = vel.limit_length(max_speed)
		
		# Damping
		vel -= vel * delta * damping
		
		set_velocity(vel)
		move_and_slide()

func seek_force(target: Vector3):	
	var toTarget = target - global_transform.origin
	toTarget = toTarget.normalized()
	var desired = toTarget * max_speed
	return desired - vel

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

func get_sine():
	return sin(sine_time*movement_amplitude)*movement_frequency


