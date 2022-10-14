extends Control

signal settings_menu_closed

# Paths to each of the buttons and sliders and stuff inside this menu.
# They are changed via the Inspector.

# Video settings.
export var path_fullscreen_options_button: NodePath
export var path_vsync_button: NodePath
export var path_bloom_button: NodePath

# Audio settings.
export var path_volume_slider: NodePath

# Gameplay settings.
export var path_fov_value: NodePath
export var path_mouse_sensitivity_value: NodePath

var all_settings = {}

func _ready():
	Global.connect("settings_changed", self, "_on_settings_changed")
	# Get references to all the buttons and stuff from the nodepaths.
	
	# Video settings.
	var fullscreen_options_button = get_node(path_fullscreen_options_button)
	#var vsync_button = get_node(path_vsync_button)
	#var bloom_button = get_node(path_bloom_button)
	
	# Audio settings.
	#var volume_slider = get_node(path_volume_slider)
	
	# Gameplay settings.
	#var fov_value = get_node(path_fov_value)
	#var mouse_sensitivity_value = get_node(path_mouse_sensitivity_value)
	
	# Add it all to this dictionary so we can pass it into the read_settings_data().
	var settings_dictionary = {
		"fullscreen_options_button":fullscreen_options_button
	}
	
	# Add it to all_settings to make it accessible for the whole script.
	all_settings.merge(settings_dictionary)
	
	read_settings_data()

# If ESCAPE is pressed, hide this settings menu.
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		hide()
		emit_signal("settings_menu_closed")

func _on_settings_changed():
	read_settings_data()

func read_settings_data():
	# Adjusts the buttons and sliders to the current settings, in case they were changed elsewhere.
	all_settings.fullscreen_options_button.pressed = Save.game_data.fullscreen_on

func _on_FullscreenToggle_toggled(button_pressed):
	Global.toggle_fullscreen(button_pressed)
