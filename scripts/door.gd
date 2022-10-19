extends MeshInstance

var is_door_open = false

onready var animation_player = $AnimationPlayer

func _ready():
	pass

func _on_Player_correct_answer():
	# So that we only open the door once.
	if !is_door_open:
		animation_player.play("open", -1.0, 1)
		is_door_open = true
	else:
		pass
