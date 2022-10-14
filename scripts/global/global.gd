extends Node

# Global functions that can be called anywhere.
#
# Signals are grouped together with their corresponding
# functions, for ease of search.

func instantiate_node(packed_scene, pos=null, parent=null):
	var clone = packed_scene.instance()
	
	var root = get_tree().root
	if parent == null:
		parent = root.get_child(root.get_child_count()-1)
	
	parent.add_child(clone)
	
	if pos != null:
		clone.global_transform.origin = pos
	
	return clone


###################
# UI
###################
# For each of these functions, we change the relevant value in the game_data dictionary.
# This game_data is then written to the actual save file.

signal settings_changed

func _input(event):
	# Input related to settings.
		if event.is_action_pressed("f11"):
			if OS.window_fullscreen:
				Global.toggle_fullscreen(false)
			else:
				Global.toggle_fullscreen(true)
			
			# Make sure all UI elements know that the settings have been changed.
			emit_signal("settings_changed")

# VIDEO SETTINGS
func toggle_fullscreen(value:bool):
	OS.window_fullscreen = value
	Save.game_data.fullscreen_on = value
	Save.save_data()

func toggle_vsync(value:bool):
	OS.vsync_enabled = value

signal bloom_toggled(value)
func toggle_bloom(value:bool):
	emit_signal("bloom_toggled", value)

# AUDIO SETTINGS


# GAMEPLAY SETTINGS
signal fov_updated(value)
func update_fov(value):
	emit_signal("fov_updated", value)

signal mouse_sensitivity_updated(value)
func update_mouse_sensitivity(value):
	emit_signal("mouse_sensitivity_updated")
