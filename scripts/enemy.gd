extends KinematicBody

enum {
	IDLE,
	ALERT,
	STUNNED
}

var state = IDLE

export var health = 200
var armour = 0

onready var animation_player = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func damage(damage):
	health -= (damage)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if health <= 0:
		queue_free()
	match state:
		IDLE:
			animation_player.play("char_one_handed_idle_loop")
		ALERT:
			animation_player.play("char_walk_loop")
		STUNNED:
			animation_player.play("char_walk_backwards_loop")
			
