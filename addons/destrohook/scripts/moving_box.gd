extends CSGBox3D


func _physics_process(delta: float) -> void:
	position.y = sin(Time.get_ticks_msec() * 0.001) * 5.0
