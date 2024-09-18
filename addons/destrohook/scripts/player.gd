extends CharacterBody3D

@export_group("misc settings")
@export var  HOOK_AVAILIBLE_TEXTURE : CompressedTexture2D##texture for crosshair when hook can be used
@export var HOOK_NOT_AVAILIBLE_TEXTURE : CompressedTexture2D##texture for crosshair when hook can't be used

@export var camera : Camera3D ##reference to the camera
@export var hook_raycast: RayCast3D ##reference to the hook raycast
@export var crosshair: TextureRect ##reference to crosshair texturerect

@export var mouse_sensetivity := 1.0 ##how fast the mouse moves
@export var hook_controller: HookController ##reference to the node with the hook controller

@export_group("movement settings")
@export var jump_force := 10.0 ##the force applied when jumping
@export var gravity := 0.5 ##the force applied downwards
@export var acceleration = 10.0  ## How quickly the player accelerates
@export var deceleration = 8.0  ## How quickly the player decelerates when no input is pressed
@export var max_speed = 25.0##the speed the player will be moving at
@export var control = 1.0##how much control the player has over the movement

@export_group("control settings")
@export var max_control = 1.0##control when not swinging
@export var slow_control = 0.05##control when swinging slowly
@export var medium_control = 0.15##control when swining a with a bit of speed
@export var fast_control = 0.25##control when swining fast

@export var slow_speed = 15.0##when the player is moving too slowly
@export var medium_speed = 20.0##when the player is moving a bit
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _physics_process(delta: float) -> void:
	# Horizontal movement
	var movement_direction: Vector2 = Input.get_vector("move_left", "move_right", "move_backward", "move_forward")
	var movement_vector: Vector3 = (transform.basis * Vector3(movement_direction.x, 0, -movement_direction.y)).normalized()

	if hook_controller.is_hook_launched and !is_on_floor():
		max_speed = 25.0#changing values of speed, so the player is faster when swinging around
	else:
		max_speed = 15.0#speed when on floor


	if is_on_floor():#this changes how much control the player has while on the floor, while swinging around(dependant on speed), you want it low so the player cant just walk upwards
		control = max_control
	else:
		if velocity.length() < slow_speed:
			control = slow_control
		elif velocity.length() < medium_speed:
			control = medium_control
		else:
			control = fast_control
			
	if movement_direction.length() != 0:#this smooths the movement, smooth movement is mandatory, as without it, the player can just walk on air while swinging
		velocity.x = lerpf(velocity.x, movement_vector.x * max_speed, acceleration * control * delta)
		velocity.z = lerpf(velocity.z, movement_vector.z * max_speed, acceleration * control * delta)
	else:
		velocity.x = lerpf(velocity.x, 0, deceleration * control * delta)
		velocity.z = lerpf(velocity.z, 0, deceleration * control * delta)
		
	# Gravity & Jumping
	if not is_on_floor():
		velocity.y -= gravity
	elif Input.is_action_pressed("action_jump"):
		velocity.y = jump_force
	
	move_and_slide()
	
	# UI, shows and hides the icon in the middle when looking at objects you can hook
	crosshair.texture = HOOK_AVAILIBLE_TEXTURE if hook_raycast.is_colliding() and not hook_controller.is_hook_launched else HOOK_NOT_AVAILIBLE_TEXTURE


func _unhandled_input(event: InputEvent) -> void:#handles the camera movement
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotation_degrees.y -= event.relative.x * 0.06 * mouse_sensetivity
		
		camera.rotation_degrees.x -= event.relative.y * 0.06 * mouse_sensetivity
		
		camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, -90, 90)
