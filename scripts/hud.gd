extends Control

var item_ui
var health_ui
var display_ui
var slot_ui
var background

onready var pause_menu = $PauseMenu

func _enter_tree():
	item_ui = $Background/ItemUI
	health_ui = $Background/ItemUI
	display_ui = $Background/Display/ItemTexture
	slot_ui = $Background/Display/ItemSlot
	background = $Background

func _ready():
	# Hide the prompt and pause menu when the game is started.
	hide_interaction_prompt()
	pause_menu.hide()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		hide_interaction_prompt()
		background.hide()
		pause_menu.show()
		#pause_menu.set_paused(true)
		pause_menu.test()

func update_item_ui(item_data, item_slot):
	slot_ui.text = item_slot
	display_ui.texture = item_data["Image"]
	
	if item_data["Name"] == "Unarmed":
		item_ui.text = item_data["Name"]
		return
	
	item_ui.text = item_data["Name"] + ": " + item_data["Ammo"] + "/" + item_data["ExtraAmmo"]

# Show/hide interaction prompt.
func show_interaction_prompt(description="Interact"):
	$InteractionPrompt.visible = true
	$InteractionPrompt/Key.text = get_key_from_action("interact") # In case input settings are changed.
	$InteractionPrompt/Description.text = description # By default, this is 'Interact'.

func hide_interaction_prompt():
	$InteractionPrompt.visible = false

# Gets the keyboard key from an action.
# This is so that the interaction prompt can show what key to press in case the input
# mapping for the action 'interact' is changed by the user.
func get_key_from_action(action):
	var key_string: String = ""

	InputMap.get_actions()
	for a in InputMap.get_action_list(action):
		key_string += OS.get_scancode_string(a.scancode)

	return key_string
