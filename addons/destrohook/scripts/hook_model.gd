extends Node3D


@export var rope : Node3D ##node of the rope
@export var rope_mesh : MeshInstance3D ##Mesh of the rope
@export var rope_visial_end : Marker3D ##where the rope will attach to the hook
@export var hook_end : Node3D##node for the hook
#for some reason the hook end was moving around a bit while the player was swinging, I maybe fixed that by using top level on some nodes transforms for the hook
@export var time_to_reach_hook_mult = 5##this will change how much time it takes for the rope to extend to the collision point, 1 is slow, 10 is instant
var distance_to_go : float#how far the rope has to travel to get to the hook
func _ready() -> void:
	#disables the wiggle shader after 0.15 seconds
	rope_mesh.material_override.set_shader_parameter("active", 1.0)
	await get_tree().create_timer(0.15).timeout
	rope_mesh.material_override.set_shader_parameter("active", 0.0)
func extend_from_to(source_position: Vector3, target_position: Vector3, target_normal: Vector3, _delta : float) -> void:
	#handles how the rope and hook move
	hook_end.global_position = target_position
	_align_hook_end_with_surface(target_normal)
	
	global_position = source_position
	var visual_target_position: Vector3 = _get_visual_target(target_position)
	var distance_to_target = global_position.distance_to(visual_target_position)
	distance_to_go = lerpf(distance_to_go, distance_to_target, _delta * time_to_reach_hook_mult)
	rope_mesh.mesh.height = distance_to_go
	rope_mesh.position.z = -distance_to_go / 2
	
	rope.look_at(visual_target_position)

func _align_hook_end_with_surface(target_normal: Vector3) -> void:
	# This function compensates for the possible error of "look_at()" function
	# when model has to look strait up/down.
	
	if target_normal.dot(Vector3.UP) > 0.001 or target_normal.y < 0:
		if target_normal.y > 0:
			hook_end.rotation_degrees.x = -90
		
		elif target_normal.y < 0:
			hook_end.rotation_degrees.x = 90
	
	else:
		hook_end.look_at(hook_end.global_position - target_normal)


func _get_visual_target(default_value: Vector3) -> Vector3:
	# This function is here because it takes some time to load a hook end model, so
	# this functions uses the physical pull target while the visual marker is loading.
	if rope_visial_end:
		return rope_visial_end.global_position
	
	else:
		return default_value
