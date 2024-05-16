extends Node3D

var default_speed : float = 2.0
var default_max_speed : float = 3.0
var default_damping : float = 1.0
var default_snake_length : int = 20
var default_slither_frequency : float = 0.5
var default_slither_radius : int = 7
var default_slither_amplitude : int = 100
var default_slither_distance : int = 1
var default_seek_radius : int = 25

@export var speed : float = 4.0
@export var max_speed : float = 5.0
@export var damping : float = 1.0
@export var snake_length : int = 20
@export var slither_frequency : float = 0.3
@export var slither_radius : int = 10
@export var slither_amplitude : int = 60
@export var slither_distance: int = 1
@export var seek_radius : int = 25

@onready var entity = get_node("entity")
@onready var snakeHead = get_node("entity/snakeHead")
@onready var harmonic = get_node("entity/snakeHead/Behaviour_Harmonic")
@onready var wanderState = get_node("entity/snakeHead/State_Wander")
@onready var spineAnimation = get_node("entity/spineAnimation")

var snake_body_pieces_scene
@onready var snakeTail = get_node("entity/tail")

var old_snakeLength = snake_length

func _ready():
	snake_body_pieces_scene = preload("res://Scene/snake_bodypiece.tscn")
	generate_body()
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

func generate_body():
	for i in snake_length:
		var body_instance = snake_body_pieces_scene.instantiate()
		
		entity.add_child(body_instance)
		
		body_instance.position.x = -i-1
		#body_instance.scale = Vector3(3,3,3)
		
	snakeTail.position.x = -snake_length-1
	#snakeTail.scale = Vector3(3,3,3)
	
	spineAnimation.bonePaths = []
	spineAnimation.bonePaths.append(snakeHead.get_path())
	
	for i in entity.get_children():
		if "CharacterBody3D" in i.name or "body" in i.name:
			spineAnimation.bonePaths.append(i.get_path())
	spineAnimation.bonePaths.append(snakeTail.get_path())
	
	spineAnimation.calculateOffsets()
