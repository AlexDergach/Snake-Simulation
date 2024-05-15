extends Node3D

var default_speed : float = 2.0
var default_max_speed : float = 3.0
var default_damping : float = 1.0
var default_snake_length : int = 7
var default_slither_frequency : float = 0.5
var default_slither_radius : int = 7
var default_slither_amplitude : int = 100
var default_slither_distance : int = 1
var default_seek_radius : int = 25

@export var speed : float = default_speed
@export var max_speed : float = default_max_speed
@export var damping : float = default_damping
@export var snake_length : int = default_snake_length
@export var slither_frequency : float = default_slither_frequency
@export var slither_radius : int = default_slither_radius
@export var slither_amplitude : int = default_slither_amplitude
@export var slither_distance: int = default_slither_distance
@export var seek_radius : int = default_seek_radius

@onready var entity = get_node("entity")
@onready var snakeHead = get_node("entity/snakeHead")
@onready var harmonic = get_node("entity/snakeHead/Behaviour_Harmonic")
@onready var wanderState = get_node("entity/snakeHead/State_Wander")
@onready var spineAnimation = get_node("entity/spineAnimation")

var snake_body_pieces_scene = preload("res://Scene/snake_bodypiece.tscn")
@onready var snakeTail = get_node("entity/tail")



var old_snakeLength = snake_length

func _ready():
	pass

func _process(delta):
	snakeHead.speed = speed
	snakeHead.max_speed = speed
	snakeHead.damping = damping
	
	harmonic.frequency = slither_frequency
	harmonic.radius = slither_radius
	harmonic.amplitude = slither_amplitude
	harmonic.distance = slither_distance
	
	wanderState.radius = seek_radius
	
	if snake_length != old_snakeLength:
		generate_body()
		old_snakeLength = snake_length
		
		spineAnimation.bonePaths = []
		
		spineAnimation.bonePaths.append(snakeHead.get_path())
		for i in entity.get_children():
			if "body" in i.name:
				spineAnimation.bonePaths.append(i.get_path())
		spineAnimation.bonePaths.append(snakeTail.get_path())

func generate_body():
	for i in snake_length:
		var body_instance = snake_body_pieces_scene.instantiate()
		
		add_child(body_instance)
		
		body_instance.position.x = -i+1/2
		
	snakeTail.position.x = -snake_length+1/2
	
