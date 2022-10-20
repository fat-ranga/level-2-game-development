extends Area

export(int) var ammo = 10

func _on_SecretIntel_body_entered(body):
	if body.is_in_group("Player"):
		# Win the game.
		get_tree().change_scene("res://victory.tscn")
