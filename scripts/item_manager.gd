extends Spatial

# All items in the game.
var all_items = {}

# Items we are currently carrying.
var items = {}

var hud

var current_item
var current_item_slot = "Melee"

var changing_item = false
var unequipped_item = false

var item_index = 0 # For switching items via scroll wheel.


# Called when the node enters the scene tree for the first time.
func _ready():
	hud = owner.get_node("HUD")
	# Add exception of player to the shooting raycast.
	owner.get_node("Head/Camera/AimCast").add_exception(owner)
	
	all_items = {
		"Unarmed": preload("res://scenes/items/unarmed.tscn"),
		"AK 47": preload("res://scenes/items/ak_47.tscn"),
		"Pistol": preload("res://scenes/items/pistol.tscn")
	}
	
	items = {
		"Melee": $Unarmed,
		"Primary": $Pistol,
		"Secondary": $AK47
	}
	
	# Initialise references for each item.
	for i in items:
		if items[i] != null:
			items[i].item_manager = self
			items[i].player = owner
			items[i].ray = owner.get_node("Head/Camera/AimCast")
			items[i].visible = false
	
	# Set current item to unarmed.
	current_item = items["Melee"]
	change_item("Melee")
	
	# Disable process.
	set_process(false)

# Process will be called when changing items.
func _process(delta):
	if unequipped_item == false:
		if current_item.is_unequip_finished() == false:
			return
		unequipped_item = true
		
		current_item = items[current_item_slot]
		current_item.equip()
		
	if current_item.is_equip_finished() == false:
		return
	
	changing_item = false
	set_process(false)

func change_item(new_item_slot):
	if new_item_slot == current_item_slot:
		current_item.update_ammo() # Refresh.
		return
	
	if items[new_item_slot] == null:
		return
	
	current_item_slot = new_item_slot
	changing_item = true
	
	items[current_item_slot].update_ammo() # Updates the weapon data on UI, as soon as we change an item.
	update_item_index()
	
	# Change items.
	if current_item != null:
		unequipped_item = false
		current_item.unequip()
	
	set_process(true)

# Scroll item change.
func update_item_index():
	match current_item_slot:
		"Melee":
			item_index = 0
		"Primary":
			item_index = 1
		"Secondary":
			item_index = 2

func next_item():
	item_index += 1
	
	if item_index >= items.size():
		item_index = 0
	
	change_item(items.keys()[item_index])

func previous_item():
	item_index -= 1
	
	if item_index < 0:
		item_index = items.size() - 1
	
	change_item(items.keys()[item_index])

# Firing and reloading.
func fire():
	if not changing_item:
		current_item.fire()

func fire_stop():
	current_item.fire_stop()

func reload():
	# We can only reload if we are not in the middle of changing out item.
	if not changing_item:
		current_item.reload()

# For ammo pickups.
func add_ammo(amount):
	if current_item == null || current_item_slot == "Melee":
		return false
	
	current_item.update_ammo("add", amount)
	return true

func update_hud(item_data):
	var item_slot = "1"
	
	match current_item_slot:
		"Melee":
			item_slot = "1"
		"Primary":
			item_slot = "2"
		"Secondary":
			item_slot = "3"
	
	hud.update_item_ui(item_data, item_slot)
