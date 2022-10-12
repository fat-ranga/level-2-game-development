extends Control

var item_ui
var health_ui
var display_ui
var slot_ui
var background
var interaction_prompt
var interaction_prompt_key
var interaction_prompt_description

onready var pause_menu = $PauseMenu

func _enter_tree():
	item_ui = $Background/ItemUI
	health_ui = $Background/ItemUI
	display_ui = $Background/Display/ItemTexture
	slot_ui = $Background/Display/ItemSlot
	background = $Background
	interaction_prompt = $InteractionPrompt
	interaction_prompt_key = $InteractionPrompt/Key
	interaction_prompt_description = $InteractionPrompt/MarginContainer/Description
	

func _ready():
	# Hide the prompt and pause menu when the game is started.
	hide_interaction_prompt()
	pause_menu.hide()

func _input(event):
	# If escape key is pressed, open the pause menu and pause the game.
	if event.is_action_pressed("ui_cancel"):
		hide_interaction_prompt()
		background.hide()
		pause_menu.show()
		pause_menu.set_paused(true)

func update_item_ui(item_data, item_slot):
	slot_ui.text = item_slot
	display_ui.texture = item_data["image"]
	
	# If the item is a melee weapon, just show the name.
	if item_data["slot_type"] == "Melee" || item_data["slot_type"] == "Any":
		item_ui.text = item_data["name"]
		return
	
	# Otherwise, it must be a weapon with ammunition.
	item_ui.text = item_data["name"] + ": " + item_data["ammo"] + "/" + item_data["extra_ammo"]

# Show/hide interaction prompt.
func show_interaction_prompt(description="Interact"):
	interaction_prompt.visible = true
	interaction_prompt_key.text = get_key_from_action("interact") # In case input settings are changed.
	interaction_prompt_description.text = description # By default, this is 'Interact'.

func hide_interaction_prompt():
	interaction_prompt.visible = false

# Gets the keyboard key from an action.
# This is so that the interaction prompt can show what key to press in case the input
# mapping for the action 'interact' is changed by the user.
func get_key_from_action(action):
	var key_string: String = ""

	InputMap.get_actions()
	for a in InputMap.get_action_list(action):
		key_string += OS.get_scancode_string(a.scancode)

	return key_string

# If the pause menu is closed, show all our UI again.
func _on_PauseMenu_pause_menu_closed():
	background.show()
