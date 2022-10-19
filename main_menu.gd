extends Control

# Reference to our settings menu.
onready var settings_menu = $SettingsMenu
onready var buttons_container = $VBoxContainer
onready var start_button = $VBoxContainer/StartButton

var is_settings_hidden = true

# Called when the node enters the scene tree for the first time.
func _ready():
	# Make sure the mouse can move around.
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# By default, set the Start button as the focus, so that when one presses
	# 'Enter', the game is started. Also lets users use arrows to navigate the menu.
	buttons_container.show()
	start_button.grab_focus()

# Start the game.
func _on_StartButton_pressed():
	get_tree().change_scene("res://world.tscn")

# Open the settings menu.
func _on_SettingsButton_pressed():
	buttons_container.hide()
	settings_menu.show()

# Exit the game.
func _on_ExitButton_pressed():
	get_tree().quit()

# If the settings menu is hidden, then we enable all our other buttons.
func _on_SettingsMenu_hide():
	buttons_container.show()
