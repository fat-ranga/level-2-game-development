extends Control

# Reference to our buttons so we can show and hide them.
onready var buttons_container = $VBoxContainer
onready var restart_button = $VBoxContainer/RestartButton

func _ready():
	# Make sure the mouse can move around.
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	pause_mode = Node.PAUSE_MODE_PROCESS # Makes sure this menu is unaffected by pausing the world.
	show() # By default, the pause menu isn't shown.
	restart_button.grab_focus() # Default to the restart button for keyboard focus

# Unpause the game and continue gameplay.
func _on_RestartButton_pressed():
	hide()
	# Restart the current level.
	get_tree().change_scene("res://level_0.tscn")

# Go back to the main menu.
func _on_BackToMainMenuButton_pressed():
	get_tree().change_scene("res://main_menu.tscn")

# If the exit button is pressed, exit the game.
func _on_ExitGameButton_pressed():
	get_tree().quit()


