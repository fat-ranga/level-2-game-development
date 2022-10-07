extends Control

signal pause_menu_closed

# Setting this variable calls the set_paused() function, but we never actually set it anywhere.
# world_is_paused is only used to check things, like whether we should hide the mouse or not.
# Always directly use set_paused() instead, like 'pause_menu.set_paused(true)'.
var world_is_paused = false setget set_paused

# Reference to our buttons so we can show and hide them.
onready var buttons_container = $VBoxContainer
onready var resume_button = $VBoxContainer/ResumeButton

# Reference to the settings menu, which is opened with the 'settings' button.
onready var settings_menu = $SettingsMenu

func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS # Makes sure pause menu is unaffected by pausing the world.
	hide() # By default, the pause menu isn't shown.
	resume_button.grab_focus() # Default to the resume button for keyboard focus

func set_paused(value):
	world_is_paused = value # Used to check if the world is paused.
	get_tree().paused = value # Pause the whole world.
	# If we're in the pause menu, show the mouse. Hide the mouse during gameplay.
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if world_is_paused == true else Input.MOUSE_MODE_CAPTURED)

# If ESCAPE is pressed, hide this pause menu. Same as pressing 'Resume' button.
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		print("cracka")
		set_paused(false)
		hide()
		emit_signal("pause_menu_closed")

# Unpause the game and continue gameplay.
func _on_ResumeButton_pressed():
	set_paused(false)
	hide()
	emit_signal("pause_menu_closed")

# Show the settings panel.
func _on_SettingsButton_pressed():
	buttons_container.hide()
	settings_menu.show()

# Go back to the main menu.
func _on_BackToMainMenuButton_pressed():
	# Important that we unpause the world, otherwise we
	# can't click anything in the main menu.
	set_paused(false)
	get_tree().change_scene("res://main_menu.tscn")

# If the exit button is pressed, exit the game.
func _on_ExitGameButton_pressed():
	get_tree().quit()

# If the settings menu is closed, show our settings buttons again.
func _on_SettingsMenu_settings_menu_closed():
	buttons_container.show()
