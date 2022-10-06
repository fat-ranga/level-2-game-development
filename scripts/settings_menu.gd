extends Control

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

func _ready():
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
	
	# When this 
	fullscreen_options_button.pressed = Save.game_data.fullscreen_on

# If ESCAPE is pressed, hide this settings menu.
func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		hide()


func _on_FullscreenToggle_toggled(button_pressed):
	Global.toggle_fullscreen(button_pressed)
