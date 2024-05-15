class_name SpineAnimator extends Node

@export var bonePaths = []
@export var damping:float = 7
@export var angular_damping:float = 20
				
var bones = [] 
var offsets = [] 

func calculateOffsets():
	bones.clear()
	offsets.clear()
	for i in bonePaths.size():
		var bone = get_node(bonePaths[i])
		bones.push_back(bone)
		if i > 0:
			var offset = bones[i].global_transform.origin - bones[i-1].global_transform.origin
			offset = bones[i-1].global_transform.basis.inverse() * offset
			offsets.push_back(offset)

func _ready():
	calculateOffsets()

func _physics_process(delta):
	for i in offsets.size():
		var prev = bones[i]
		var next = bones[i + 1]
		
		var wantedPos = prev.global_transform * (offsets[i])
		
		var lerped = lerp(next.global_transform.origin, wantedPos, delta * damping)
		var limit_length = (lerped - prev.global_transform.origin).normalized() * offsets[i].length()
		var pos = prev.global_transform.origin + limit_length
		next.global_transform.origin = pos
		
		var prevRot = prev.global_transform.basis.orthonormalized()
		
		var target_rot = prev.global_transform.looking_at(next.global_transform.origin, prev.global_transform.basis.y).basis.orthonormalized()
		next.global_transform.basis = next.global_transform.basis.slerp(target_rot, angular_damping * delta).orthonormalized()
		

