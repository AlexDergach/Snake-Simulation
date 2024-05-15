class_name State_Wander extends State

var boid
var prey


func _enter():
	boid.get_node("Behaviour_Wander").set_enabled(true)
	boid.get_node("Behaviour_Avoidance").set_enabled(true)
	
	

func _exit():
	boid.get_node("Behaviour_Wander").set_enabled(false)

func _think():
	if prey.distance_to(boid.global_transform.origin) < 5:
		var AttackState = load("res://AttackState.gd")
		boid.get_node("StateMachine").change_state(AttackState.new())

func _ready():
	boid = get_parent()
