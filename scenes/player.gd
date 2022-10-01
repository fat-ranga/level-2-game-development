extends KinematicBody

# Movement.
var walk_speed: float = 10.0
var air_acceleration: float = 2.0
var regular_acceleration: float = 10.0
var h_acceleration: float = 10.0 # Determined by either air or regular acceleration.
var jump_power: float = 10.0
var gravity: float = 20.0
var full_contact: bool = false

var gravity_vector: Vector3 = Vector3()
var direction: Vector3 = Vector3()
var h_velocity: Vector3 = Vector3()
var movement: Vector3 = Vector3()

var mouse_sensitivity: float = 0.06

# References to other nodes in our player scene.
onready var head = $Head
onready var ground_check = $GroundCheck

# Called when the node enters the scene tree for the first time.
func _ready():
	# Keep the mouse positioned at screen centre.
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		# Looking around.
		rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
		head.rotate_x(deg2rad(event.relative.y * mouse_sensitivity))
		head.rotation.x = clamp(head.rotation.x, deg2rad(-90), deg2rad(70))

func _physics_process(delta):
	# Which way we are going to move.
	direction = Vector3()
	
	# Check if we're on the ground or not.
	if ground_check.is_colliding():
		full_contact = true
	else:
		full_contact = false
	
	# Change gravity direction so we stick to slopes if moving down them.
	if not is_on_floor():
		gravity_vector += Vector3.DOWN * gravity * delta
		h_acceleration = air_acceleration
	elif is_on_floor() and full_contact:
		gravity_vector = -get_floor_normal() * gravity
		h_acceleration = regular_acceleration
	else:
		gravity_vector = -get_floor_normal()
		h_acceleration = regular_acceleration
	
	# Jumping.
	if Input.is_action_pressed("jump") and (is_on_floor() or ground_check.is_colliding()):
		gravity_vector = Vector3.UP * jump_power
	
	# Forwards/backwards and left/right input and movement.
	direction += transform.basis.x * (Input.get_action_strength("move_left") - Input.get_action_strength("move_right"))
	direction += transform.basis.z * (Input.get_action_strength("move_forwards") - Input.get_action_strength("move_backwards"))
	
	# Ensure we aren't faster when moving diagonally.
	direction = direction.normalized()
	# Smooth acceleration.
	h_velocity = h_velocity.linear_interpolate(direction * walk_speed, h_acceleration * delta)
	# Movement vector calculated from direction and gravity.
	movement.z = h_velocity.z + gravity_vector.z
	movement.x = h_velocity.x + gravity_vector.x
	movement.y = gravity_vector.y
	
	# Actually move the player.
	move_and_slide(movement, Vector3.UP)
	
