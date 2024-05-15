class_name Behaviour_Avoidance extends SteeringBehavior

enum ForceDirection {Normal, Incident, Up, Braking}
@export var direction = ForceDirection.Normal
@export var feeler_angle = 45
@export var feeler_length = 10
@export var updates_per_second = 5

var force = Vector3.ZERO
var feelers = []
var space_state
var needs_updating = true

func on_draw_gizmos():
	for i in feelers.size():
		var feeler = feelers[i]
		
		if feeler.hit:
			DebugDraw3D.draw_line(snake.global_transform.origin, feeler.hit_target, Color.CHARTREUSE)
			DebugDraw3D.draw_arrow(feeler.hit_target, feeler.hit_target + feeler.normal, Color.BLUE, 0.1)
			DebugDraw3D.draw_arrow(feeler.hit_target, feeler.hit_target + feeler.force * weight, Color.RED, 0.1)			
		else:
			DebugDraw3D.draw_line(snake.global_transform.origin, feeler.end, Color.CHARTREUSE)

func start_updating():
	
	var timer = get_child(0)
	timer.disconnect("timeout", Callable(self, "start_updating"))
	timer.wait_time = 1.0 / updates_per_second	
	timer.connect("timeout", Callable(self, "on_needs_updating"))
	
	timer.one_shot = false
	timer.start()


func on_needs_updating():
	needs_updating = true

func _physics_process(delta):
	if needs_updating:
		update_feelers()
		needs_updating = false

func feel(local_ray):
	var feeler = {}
	var ray_end = snake.global_transform * (local_ray)
	var query = PhysicsRayQueryParameters3D.create(snake.global_transform.origin, ray_end, snake.collision_mask)
	var result = space_state.intersect_ray(query)
	feeler.end = ray_end
	feeler.hit = result
	if result:
		feeler.hit_target = result.position
		feeler.normal = result.normal
		var to_snake = snake.global_transform.origin - result.position 
		var force_mag = ((feeler_length - to_snake.length()) / feeler_length)
		match direction:
			ForceDirection.Normal:
				feeler.force = result.normal * force_mag
			ForceDirection.Incident:
				feeler.force = to_snake.reflect(result.normal).normalized() * force_mag
			ForceDirection.Up:
				feeler.force = Vector3.UP * force_mag
			ForceDirection.Braking:
				feeler.force = to_snake.normalized() * force_mag
		force += feeler.force
	return feeler

func update_feelers():
	force = Vector3.ZERO
	feelers.clear()
	var forwards = Vector3.BACK * feeler_length
	feelers.push_back(feel(forwards))
	feelers.push_back(feel(Quaternion(Vector3.UP, deg_to_rad(feeler_angle)) * forwards))
	feelers.push_back(feel(Quaternion(Vector3.UP, deg_to_rad(-feeler_angle)) * forwards))

	feelers.push_back(feel(Quaternion(Vector3.RIGHT, deg_to_rad(-feeler_angle)) * forwards))

func calculate():
	return force

func _ready():
	snake = get_parent()
	space_state = snake.get_world_3d().direct_space_state
	
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = randf_range(0.0, 1.0)
	timer.one_shot = true
	timer.connect("timeout", Callable(self, "start_updating"))
	timer.start()
