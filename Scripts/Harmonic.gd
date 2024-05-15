class_name Behaviour_Harmonic extends SteeringBehavior

@export var frequency = 1
@export var radius = 10.0

@export var amplitude = 150
@export var distance = 5

enum Axis { Horizontal, Vertical}
@export var axis = Axis.Horizontal
var target:Vector3
var worldTarget:Vector3

var theta
	
func _ready():
	snake = get_parent()
	theta = randf_range(0, PI * 2.0)
	
#func on_draw_gizmos():
	#snake = get_parent()
	#var cent = snake.global_transform * (Vector3.BACK * distance)
	#DebugDraw3D.draw_sphere(cent, radius, Color.HOT_PINK)
	#DebugDraw3D.draw_line(snake.global_transform.origin, cent, Color.HOT_PINK)
	#DebugDraw3D.draw_line(cent, worldTarget, Color.HOT_PINK)
	

func calculate():		
	var n  = sin(theta)
	var angle = deg_to_rad(n * amplitude)
	
	var delta = get_process_delta_time()

	var rot = snake.global_transform.basis.get_euler()
	rot.x = 0

	if axis == Axis.Horizontal:
		target.x = sin(angle)
		target.z =  cos(angle)
		target.y = 0
		rot.z = 0
	else:
		target.x = 0
		target.y = sin(angle)
		target.z = cos(angle)
	
	target *= radius

	var localtarget = target + (Vector3.BACK * distance)
	
	var projected = Basis.from_euler(rot)
	
	worldTarget = snake.global_transform.origin + (projected * localtarget)	
	theta += frequency * delta * PI * 2.0
	
	var f = snake.seek_force(worldTarget)  

	return f
