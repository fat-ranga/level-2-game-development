extends KinematicBody

export var health = 200
var armour = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func damage(damage):
	health -= (damage)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if health <= 0:
		queue_free()
