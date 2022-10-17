extends KinematicBody

enum {
	IDLE,
	ALERT,
	MOVING,
	STUNNED
}

const TURN_SPEED = 2

var state = IDLE
var target

export var health = 50
var armour = 0

onready var animation_player = $AnimationPlayer
onready var eyes = $Eyes
onready var shoot_timer = $ShootTimer
onready var raycast = $RayCast
onready var nav = get_parent()

# Pathfinding.
var path = []
var path_node = 0
var speed = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	# If we have no health, then die.
	if health <= 0:
		die()
	
	# Enemy state machine.
	match state:
		IDLE:
			animation_player.play("char_one_handed_idle_loop")
		ALERT:
			animation_player.play("char_walk_loop")
			eyes.look_at(target.global_transform.origin, Vector3.UP)
			rotate_y(deg2rad(eyes.rotation.y * TURN_SPEED))
		STUNNED:
			animation_player.play("char_walk_backwards_loop")

func _physics_process(delta):
	if path_node < path.size():
		var direction = (path[path_node] - global_transform.origin)
		if direction.length() < 1:
			path_node += 1
		# Move in the direction we set.
		move_and_slide(direction.normalized() * speed, Vector3.UP)

func update_path(target_position):
	path = nav.get_simple_path(global_transform.origin, target_position)
	path_node = 0

func _on_NavigationTimer_timeout():
	if target != null:
		update_path(target.global_transform.origin)

func damage(damage):
	health -= (damage)

func die():
	animation_player.play("die")

func _on_SightRange_body_entered(body):
	if body.is_in_group("Player"):
		state = ALERT
		target = body
		shoot_timer.start()

func _on_SightRange_body_exited(body):
	if body.is_in_group("Player"):
		state = IDLE
		shoot_timer.stop()

func _on_Timer_timeout():
	if raycast.is_colliding():
		var hit = raycast.get_collider()
		if hit.is_in_group("Player"):
			#print("Hit")
			pass



