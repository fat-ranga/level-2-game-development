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

onready var reach_ray = owner.get_node("Head/Camera/Reach")

# Called when the node enters the scene tree for the first time.
func _ready():
	hud = owner.get_node("Head/Camera/ViewportContainer/HUD")
	# Add exception of player to the shooting and reach raycast.
	owner.get_node("Head/Camera/AimCast").add_exception(owner)
	owner.get_node("Head/Camera/Reach").add_exception(owner)
	
	# Dictionary of all items in the game.
	all_items = {
		"Unarmed": preload("res://scenes/items/unarmed.tscn"),
		"AK47": preload("res://scenes/items/ak_47.tscn"),
		"Pistol": preload("res://scenes/items/pistol.tscn")
	}
	
	items = {
		"Melee": $Unarmed,
		"Primary": $Pistol,
		"Secondary": $AK47
	}
	
	# Initialise references for each item.
	for i in items:
		if is_instance_valid(items[i]):
			item_setup(items[i])
	
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

# Initialise item values.
func item_setup(item):
	item.item_manager = self
	item.player = owner
	item.ray = owner.get_node("Head/Camera/AimCast")
	item.visible = false

func change_item(new_item_slot):
	if new_item_slot == current_item_slot:
		current_item.update_ammo() # Refresh.
		return
	
	if is_instance_valid(items[new_item_slot]) == false:
		return
	
	current_item_slot = new_item_slot
	changing_item = true
	
	items[current_item_slot].update_ammo() # Updates the weapon data on UI, as soon as we change an item.
	update_item_index()
	
	# Change items.
	if is_instance_valid(current_item):
		unequipped_item = false
		current_item.unequip()
	
	set_process(true)

# Add item to an existing empty slot.
func add_item(item_data):
	if not item_data['Name'] in all_items:
		return
	
	# TODO: generic statement for this
	if is_instance_valid(items["Primary"]) == false:
		# Instantiate the new item.
		var item = Global.instantiate_node(all_items[item_data["Name"]], Vector3.ZERO, self)
		
		# Initialise the new item references.
		item_setup(item)
		item.ammo_in_magazine = item_data["Ammo"]
		item.extra_ammo = item_data["ExtraAmmo"]
		item.magazine_size = item_data["MagazineSize"]
		item.transform.origin = item.equip_position
		
		# Update the dictionary and change item.
		items["Primary"] = item
		change_item("Primary")
		
		return
	
	if is_instance_valid(items["Secondary"]) == false:
		# Instantiate the new item.
		var item = Global.instantiate_node(all_items[item_data["Name"]], Vector3.ZERO, self)
		
		# Initialise the new item references.
		item_setup(item)
		item.ammo_in_magazine = item_data["Ammo"]
		item.extra_ammo = item_data["ExtraAmmo"]
		item.magazine_size = item_data["MagazineSize"]
		item.transform.origin = item.equip_position
		
		# Update the dictionary and change item.
		items["Secondary"] = item
		change_item("Secondary")
		
		return

# Switch/replace item.
func switch_item(item_data):
	# Checks whether there is any empty slot available.
	# If there is, add the new item to that empty slot.
	for i in items:
		if is_instance_valid(items[i]) == false:
			add_item(item_data)
			return
	
	# TODO: take item's correct slot type into account
	# If we are unarmed, but all slots are full, and pick up an item,
	# the item in the primary slot will be dropped and replaced with the new item.
	if current_item.name == "Unarmed":
		items["Primary"].drop_item()
		yield(get_tree(), "idle_frame") # Wait a frame to complete deletion process of previous item.
		add_item(item_data)
	
	# If the item to picked up and the current item are the same,
	# then the ammunition of the new item is added to the currently-equipped item.
	elif current_item.item_name == item_data["Name"]:
		add_ammo(item_data["Ammo"] + item_data["ExtraAmmo"])
	
	# If we already have an equipped item,
	# then we drop it and equip the new item.
	else:
		drop_item()
		yield(get_tree(), "idle_frame") # Wait a frame to complete deletion process of previous item.
		add_item(item_data)

# Will be called from player.gd.
func drop_item():
	if current_item_slot != "Melee":
		current_item.drop_item()
		
		# Need to be set to unarmed in order to call change_item() function.
		current_item_slot = "Melee"
		current_item = items["Melee"]
		
		# Update HUD.
		current_item.update_ammo()

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
	if is_instance_valid(current_item) == false || current_item_slot == "Melee":
		return false
	
	current_item.update_ammo("add", amount)
	return true

# Interaction prompt.
func show_interaction_prompt(item_name):
	var description: String
	
	# If there is a pistol and you already have a pistol currently equipped,
	# for example, the prompt will change since you'll be just picking up
	# the ammunition.
	if current_item.item_name == item_name:
		description = "+ Add Ammunition"
	else:
		description = "Equip " + str(item_name)
	
	hud.show_interaction_prompt(description)

func hide_interaction_prompt():
	hud.hide_interaction_prompt()

# Searches for item pickups, and based on player input executes further tasks
# (will be called from player.gd)
func process_item_pickup():
	reach_ray.force_raycast_update()
	
	if reach_ray.is_colliding():
		var body = reach_ray.get_collider()
		
		if body.has_method("get_item_pickup_data"):
			var item_data = body.get_item_pickup_data()
			
			show_interaction_prompt(item_data["Name"])
			
			if Input.is_action_just_pressed("interact"):
				switch_item(item_data)
				body.queue_free()
		else:
			hide_interaction_prompt()

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
