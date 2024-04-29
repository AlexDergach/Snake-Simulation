extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const DESTINATION_CHANGE_INTERVAL = 5.0 # Change destination every 5 seconds
const FOOT_OFFSET = 0.1 # Maximum offset for foot motion

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var nav_agent = $NavigationAgent3D
var target_destination = Vector3.ZERO
var destination_change_timer = 0.0
var move = 1

@onready var foot = $Foot
@onready var foot_2 = $Foot2
@onready var foot_3 = $Foot3
@onready var foot_4 = $Foot4

var foot_offset = 0.0

func _ready():
	set_random_destination()

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	if nav_agent.is_target_reachable():
		var path = nav_agent.get_current_navigation_path()
		if path.size() > 1:
			var next_position = path[1]
			var direction = (next_position - global_transform.origin).normalized()
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
			
			# Calculate the rotation angle based on the velocity vector
			var rotation_angle = atan2(-velocity.z, velocity.x)
			rotation.y = rotation_angle
			
		else:
			set_random_destination()
	else:
		set_random_destination()

	move_and_slide()

	# Update the timer and change destination if needed
	destination_change_timer += delta
	if destination_change_timer >= DESTINATION_CHANGE_INTERVAL:
		set_random_destination()
		destination_change_timer = 0.0

func set_random_destination():
	var random_x = randi_range(-10, 10)
	var random_z = randi_range(-10, 10)
	target_destination = Vector3(random_x, 0, random_z)
	nav_agent.set_target_position(target_destination)

