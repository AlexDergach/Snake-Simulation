class_name Behaviour_Seek extends SteeringBehavior

var world_target:Vector3

func calculate():
	return snake.seek_force(world_target)

func _ready():
	snake = get_parent()
