class_name State_Attack extends State

var snake
var random_loc
var prey
var field_of_view_angle = PI / 4
@export var radius : float = 25

var collision_lock = false
@onready var timer = get_node("../Timer")

var first_point_delay = 0
@onready var attack_sound = $"../AttackSound"
@onready var mouse_sound = $"../MouseSound"
@onready var blood_particle = $"../BloodParticle/GPUParticles3D"

func _ready():
	snake = get_parent()
	

func _enter():
	# enable behaviours
	snake.get_node("Behaviour_Seek").set_enabled(true)
	snake.get_node("Behaviour_Avoidance").set_enabled(true)
	snake.get_node("Behaviour_Harmonic").set_enabled(true)
	
	prey = snake.prey
	timer.start(10)
	

func _exit():
	snake.prey = null
	snake.get_node("Behaviour_Seek").set_enabled(false)

func _think():
	
	if prey.global_position.distance_to(snake.global_position) < 10:
		if snake.get_node("Behaviour_Harmonic").is_enabled():
			snake.get_node("Behaviour_Harmonic").set_enabled(false)
			snake.get_node("Behaviour_Avoidance").set_enabled(false)
		
		snake.get_node("Behaviour_Seek").world_target = prey.global_position
		snake.get_node("Behaviour_Seek").set_enabled(true)
		snake.max_speed = 50
		snake.speed = 50
		snake.damping = -5
		
		if prey.global_position.distance_to(snake.global_position) < 3:
			attack_sound.play()
			mouse_sound.play()
			blood_particle.restart()
			
			prey.queue_free()
			snake.prey_list.erase(prey)
			
			var WanderState = load("res://Scripts/State_Wander.gd")
			snake.get_node("StateMachine").change_state(WanderState.new())
			
	
	snake.get_node("Behaviour_Seek").world_target = prey.global_position
	

func put_on_ground(loc):
	var raycast = RayCast3D.new()
	raycast.target_position = Vector3(0, -25, 0)
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

func get_state():
	return "Attack"
