extends KinematicBody

# Our enemy state machine.
enum {
	IDLE,
	MOVING,
	ATTACKING
}

var state = IDLE # Current state we are in.
var target # Thing we should move towards/shoot at.

var is_target_position_known = true
var is_target_within_range = false
var is_dead = false

export var turn_speed = 2
export var health = 50
export var damage = 3
export(PackedScene) var droppable_item

onready var collision = $CollisionShape
onready var animation_tree = $AnimationTree
onready var animation_player = $AnimationPlayer
onready var eyes = $Eyes
onready var shoot_timer = $ShootTimer
onready var raycast = $RayCast
onready var nav = get_parent()
onready var item = $HumanArmature/Skeleton/WeaponAttachment/Item

# Controls animation.
var animation_mode

# Pathfinding.
var path = []
var path_node = 0
var speed = 4

# Called when the node enters the scene tree for the first time.
func _ready():
	item.visible = true
	collision.disabled = false
	animation_mode = animation_tree["parameters/playback"]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	# If we have no health, then die.
	if health <= 0:
		die()
	
	if not is_dead:
		# Enemy state machine.
		match state:
			IDLE:
				animation_mode.travel("char_one_handed_idle_loop")
			MOVING:
				animation_mode.travel("char_walk_loop")
				eyes.look_at(target.global_transform.origin, Vector3.UP)
				rotate_y(deg2rad(eyes.rotation.y * turn_speed))
			ATTACKING:
				animation_mode.travel("char_one_handed_fire_loop")
				eyes.look_at(target.global_transform.origin, Vector3.UP)
				

func _physics_process(delta):
	if not is_dead:
		if path_node < path.size():
			var direction = (path[path_node] - global_transform.origin)
			if direction.length() < 1:
				path_node += 1
			# Move in the direction we set.
			move_and_slide(direction.normalized() * speed, Vector3.UP)

func update_path(target_position):
	# Update the path to the target.
	path = nav.get_simple_path(global_transform.origin, target_position)
	path_node = 0

func _on_NavigationTimer_timeout():
	if not is_dead:
		# This doesn't need to be calculated every frame, so we use a timer.
		if target != null:
			update_path(target.global_transform.origin)

func damage(damage):
	health -= (damage)

func die():
	animation_mode.travel("die")
	if item.visible:
		drop_item()
		item.visible = false # Hide the item, since we generate a new dropped one.
	collision.disabled = true # So we aren't trapped in a mass of dead Jack Fiddlers.
	is_dead = true

func _on_SightRange_body_entered(body):
	if not is_dead:
		if body.is_in_group("Player"):
			is_target_position_known = true
			state = MOVING
			target = body
			shoot_timer.start()

func _on_SightRange_body_exited(body):
	if not is_dead:
		if not is_target_position_known:
			if body.is_in_group("Player"):
				state = IDLE
				shoot_timer.stop()

func _on_Timer_timeout():
	if not is_dead:
		shoot()

func shoot():
	var hit = raycast.get_collider()
	if raycast.is_colliding():
		if hit.is_in_group("Player"):
			hit.damage(damage)

func drop_item():
	# Drop the pickup defined up top.
	var pickup = Global.instantiate_node(droppable_item,  global_transform.origin)
	pickup.apply_impulse(global_transform.basis.z, global_transform.basis.z * 5)


