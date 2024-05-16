class_name Behaviour_Seek extends SteeringBehavior

var world_target:Vector3

func on_draw_gizmos():
	DebugDraw3D.draw_box(world_target,Quaternion(),Vector3(1,1,1),Color.RED)

func calculate():
	
	return boid.seek_force(world_target)

func _ready():
	boid = get_parent()
