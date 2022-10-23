extends Control

func _on_ContinueButton_pressed():
	# Actually start the game.
	get_tree().change_scene("res://level_0.tscn")
