extends Control

var is_paused = false setget set_paused
onready var buttons_container = $VBoxContainer

# Reference to the settings menu, which is opened with the 'settings' button.
onready var settings_menu = $SettingsMenu

func _ready():
	# By default, the pause menu isn't shown.
	hide()

func set_paused(value):
	is_paused = value
	get_tree().paused = value
	#visible = is_paused
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if is_paused == true else Input.MOUSE_MODE_CAPTURED)
"""
func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		print(self.is_paused)
		self.is_paused = !is_paused
		print(self.is_paused)
		
#		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
#			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
#		else:
#			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
"""
func test():
	self.is_paused = !is_paused

# Unpause the game if 'Resume' is pressed.
func _on_ResumeButton_pressed():
	set_paused(false)

# Show the settings panel.
func _on_SettingsButton_pressed():
	#buttons_container.hide()
	settings_menu.show()

# Go back to the main menu.
func _on_BackToMainMenuButton_pressed():
	get_tree().change_scene("res://main_menu.tscn")

# If the exit button is pressed, exit the game.
func _on_ExitGameButton_pressed():
	get_tree().quit()
