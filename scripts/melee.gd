extends RigidBody

# GROUPS
# --------
# Items
# Droppable

export var damage = 100
export var is_droppable = true

var is_dropped = false

onready var hitbox = $Hitbox

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func use():
	# In the case of melee weapons, we attack using it.
	for body in hitbox.get_overlapping_bodies():
		if body.is_in_group("Enemy"):
			body.damage(damage)

func drop():
	# Make sure we can actually drop the object, otherwise we will get an error because of
	# 'transform.basis' if the melee weapon is not a rigidbody, like the fists.
	if is_droppable:
		apply_impulse(transform.basis.z, -transform.basis.z * 10)
		is_dropped = false
	else:
		is_dropped = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
