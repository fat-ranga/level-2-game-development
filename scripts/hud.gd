extends Control

signal correct_answer
signal self_destruct

# References to all our UI stuff in this HUD.
var item_ui
var health_ui
var display_ui
var slot_ui
var background
var interaction_prompt
var interaction_prompt_key
var interaction_prompt_description
var reticle

onready var pause_menu = $PauseMenu
onready var terminal_menu = $TerminalMenu

func _enter_tree():
	item_ui = $Background/ItemUI
	health_ui = $Background/HealthTexture/HealthUI
	display_ui = $Background/ItemTexture
	slot_ui = $Background/ItemTexture/ItemSlot
	background = $Background
	interaction_prompt = $InteractionPrompt
	interaction_prompt_key = $InteractionPrompt/Key
	interaction_prompt_description = $InteractionPrompt/MarginContainer/Description
	reticle = $Reticle
	
func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS # Makes sure pause menu is unaffected by pausing the world.
	# Hide the prompt and pause menu when the game is started.
	hide_interaction_prompt()
	pause_menu.hide()

func _input(event):
	# If escape key is pressed, open the pause menu and pause the game.
	if event.is_action_pressed("ui_cancel"):
		
		hide_interaction_prompt()
		background.hide()
		reticle.hide()
		pause_menu.show()
		pause_menu.set_paused(true)

func update_health_ui(amount):
	health_ui.text = str(amount)

func update_item_ui(item_data, item_slot):
	slot_ui.text = item_slot + ": " + item_data["name"]
	display_ui.texture = item_data["image"]
	
	# If the item is a melee weapon, just show the name.
	if item_data["slot_type"] == "Melee" || item_data["slot_type"] == "Any":
		item_ui.text = item_data["name"]
		return
	
	# Otherwise, it must be a weapon with ammunition.
	item_ui.text = item_data["ammo"] + " / " + item_data["extra_ammo"]

# Show/hide interaction prompt.
func show_interaction_prompt(description="Interact"):
	reticle.hide()
	interaction_prompt.visible = true
	interaction_prompt_key.text = get_key_from_action("interact") # In case input settings are changed.
	interaction_prompt_description.text = description # By default, this is 'Interact'.

func hide_interaction_prompt():
	interaction_prompt.visible = false
	reticle.show()

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
	reticle.show()

func _on_Player_player_died():
	get_tree().change_scene("res://scenes/ui/death_menu.tscn")

func _on_Items_terminal_opened():
	if terminal_menu.is_terminal_active:
		# Show the mouse so we can do stuff.
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		terminal_menu.show()
		hide_interaction_prompt()
		background.hide()
		reticle.hide()
		pause_menu.set_paused(true)

# Pass these to the player, who will then pass them to door/explosion.
func _on_TerminalMenu_correct_answer():
	pause_menu.set_paused(false)
	terminal_menu.hide()
	emit_signal("correct_answer")

func _on_TerminalMenu_self_destruct():
	pause_menu.set_paused(false)
	terminal_menu.hide()
	emit_signal("self_destruct")
