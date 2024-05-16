class_name Behaviour_Arrive extends SteeringBehavior

@export var target:Node3D

@export var slowing_radius:float = 20 

func on_draw_gizmos():
	if target: 
		DebugDraw3D.draw_position(target.global_transform, Color.AQUAMARINE)
		DebugDraw3D.draw_sphere(target.global_position, slowing_radius, Color.AQUAMARINE)

func calculate():
	return boid.arrive_force(target.global_position, slowing_radius)

func _ready():
	boid = get_parent()
