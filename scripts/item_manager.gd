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
var reach_ray_length = 5.0

# Called when the node enters the scene tree for the first time.
func _ready():
	hud = owner.get_node("Head/Camera/ViewportContainer/HUD")
	# Add exception of player to the shooting and reach raycast.
	owner.get_node("Head/Camera/AimCast").add_exception(owner)
	owner.get_node("Head/Camera/Reach").add_exception(owner)
	
	# Dictionary of all items in the game.
	all_items = {
		"Unarmed": preload("res://scenes/items/unarmed.tscn"),
		"AK-47": preload("res://scenes/items/ak_47.tscn"),
		"M1911": preload("res://scenes/items/pistol.tscn")
	}
	
	# Dictionary of the items we are currently carrying.
	items = {
		"Melee": $Unarmed,
		"Primary": null,
		"Secondary": null
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

func change_item(new_item_slot, scroll_direction="None"):
	if new_item_slot == current_item_slot:
		current_item.update_ammo() # Refresh.
		return
	
	# If there's nothing in the slot, try the next one or previous one
	# depending on which way the user scrolled.
	if is_instance_valid(items[new_item_slot]) == false:
		if scroll_direction == "Previous":
			previous_item()
		elif scroll_direction == "Next":
			next_item()
		else:
			return
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
	# Check if the item actually exists in the all_items dictionary, otherwise we
	# get an error when trying to instantiate an item that doesn't exist.
	if not item_data["name"] in all_items:
		print(item_data["name"])
		print(all_items)
		return
	
	# Instantiate the new item.
	var item = Global.instantiate_node(all_items[item_data["name"]], Vector3.ZERO, self)
	
	# Initialise the new item references.
	item_setup(item)
	item.ammo_in_magazine = item_data["ammo"]
	item.extra_ammo = item_data["extra_ammo"]
	item.magazine_size = item_data["magazine_size"]
	item.transform.origin = item.equip_position
	
	
	if item_data["slot_type"] == "Any":
		# If this item can go anywhere, then it just goes to the currently-equipped slot.
		items[current_item_slot] = item
		change_item(current_item_slot)
	else:
		# Update the dictionary and change current item slot to the slot of this newly-equipped item.
		items[item_data["slot_type"]] = item
		change_item(item_data["slot_type"])
	
	return

# Replace item.
func replace_item(item_data):
	# If the item can go in any slot, find the first empty (invalid) slot and add the item to it.
	if item_data["slot_type"] == "Any":
		for i in items:
			if is_instance_valid(items[i]) == false:
				add_item(item_data)
				return
	# The item must go into a specific slot, which we get from its item_data slot_type.
	else:
		if is_instance_valid(items[item_data["slot_type"]]) == false:
			# If there's not an item already in its slot, just add the item to that slot.
			add_item(item_data)
		else:
			if items[item_data["slot_type"]].item_name == item_data["name"]:
				# If the item to be picked up and the current item are the same,
				# then the ammunition of the new item is added to the currently-equipped item.
				if current_item_slot == item_data["slot_type"]:
					# Update the HUD, since the current item slot is the same as the slot
					# of the new item.
					add_ammo(item_data["ammo"] + item_data["extra_ammo"], item_data)
				else:
					# Don't update the HUD, otherwise it may do something like display
					# the ammo of an AK in the Melee slot.
					add_ammo(item_data["ammo"] + item_data["extra_ammo"], item_data, false)
			else:
				# If there is an item already in its slot, make sure to drop that item before adding the new one.
				drop_item(item_data["slot_type"])
				add_item(item_data)
		
	"""
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
	
	# If the item to be picked up and the current item are the same,
	# then the ammunition of the new item is added to the currently-equipped item.
	elif current_item.item_name == item_data["Name"]:
		add_ammo(item_data["Ammo"] + item_data["ExtraAmmo"])
	
	# If we already have an equipped item,
	# then we drop it and equip the new item.
	else:
		drop_item()
		yield(get_tree(), "idle_frame") # Wait a frame to complete deletion process of previous item.
		add_item(item_data)
	"""

# Will be called from player.gd.
# By default, the slot we want to drop an item from is the one currently equipped.
func drop_item(slot=current_item_slot):
	current_item_slot = slot
	current_item = items[current_item_slot]
	
	if current_item_slot != "Melee":
		current_item.drop_item() # All the physics and spawning is handled by the item.
		
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
	
	change_item(items.keys()[item_index], "Next")

func previous_item():
	item_index -= 1
	
	if item_index < 0:
		item_index = items.size() - 1
	
	change_item(items.keys()[item_index], "Previous")

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
func add_ammo(amount, item_data=null, update_hud=true):
	# If there is no item defined via item_data, just add the ammo to whatever
	# we have equipped.
	if is_instance_valid(item_data):
		# We cannot add ammo to a null item, or one that is melee.
		if is_instance_valid(items[item_data["slot_type"]]) == false || item_data["slot_type"] == "Melee":
			return false
		else:
			items[item_data["slot_type"]].update_ammo("add", amount, update_hud)
			return true
	else:
		current_item.update_ammo("add", amount, update_hud)
	return true

# Interaction prompt.
func show_interaction_prompt(item_data):
	var description: String
	
	# If there is not an item already in the relevant slot, we cannot add ammunition.
	# Therefore, the item must be something we can equip.
	if is_instance_valid(items[item_data["slot_type"]]) == false:
		description = "Equip " + str(item_data["name"])
		hud.show_interaction_prompt(description)
		return
	else:
		# If there is a pistol and you already have a pistol on you,
		# for example, the prompt will change since you'll be just picking up
		# the ammunition.
		if items[item_data["slot_type"]].item_name == item_data["name"]:
			description = "+ Take " + item_data["name"] + " Ammunition"
			hud.show_interaction_prompt(description)
			return
		else:
			# The items do not match.
			# Therefore, the item must be something we can equip.
			description = "Equip " + str(item_data["name"])
			hud.show_interaction_prompt(description)
			

func hide_interaction_prompt():
	hud.hide_interaction_prompt()

# Searches for item pickups, and based on player input executes further tasks
# (will be called from player.gd)
func process_item_pickup():
	var from = reach_ray.global_transform.origin
	var to = reach_ray.global_transform.origin - reach_ray.global_transform.basis.z.normalized() * reach_ray_length
	var space_state = get_world().direct_space_state
	# 524288 is the value of the item pickup collision layer.
	var collision = space_state.intersect_ray(from, to, [owner], 524288)
	
	if collision:
		var body = collision["collider"]
		
		if body.has_method("get_item_pickup_data"):
			var item_data = body.get_item_pickup_data()
			
			show_interaction_prompt(item_data)
			
			if Input.is_action_just_pressed("interact"):
				replace_item(item_data)
				body.queue_free()
	else:
		hide_interaction_prompt()

# This updates the numbers and item equipped on the HUD to reflect the current item
# equipped and its data.
func update_hud(item_data):
	# By default, the slot is melee.
	var item_slot = "Melee"
	
	match current_item_slot:
		"Melee":
			item_slot = "Melee"
		"Primary":
			item_slot = "Primary"
		"Secondary":
			item_slot = "Secondary"
	
	hud.update_item_ui(item_data, item_slot)
