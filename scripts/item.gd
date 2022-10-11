extends Spatial
class_name Item

# References.
var item_manager = null
var player = null
var ray = null

# item states.
var is_equipped = false

# Item parameters.
export var item_name = "Item"
export(Texture) var item_image = null
export(String, "Any", "Melee", "Primary", "Secondary", "Grenade", "Special") var item_slot_type = "Any"

# Equip/unequip cycle.
func equip():
	pass

func unequip():
	pass
	
func is_equip_finished():
	return true

func is_unequip_finished():
	return true

# Show/hide the item.
func show_item():
	visible = true

func hide_item():
	visible = false

func update_ammo(action="refresh", update_hud=true):
	var item_data = {
		"name": item_name,
		"image": item_image,
		"slot_type": item_slot_type
	}
	
	# This is in case we are updating the data of an item that isn't currently in hand.
	if update_hud:
		item_manager.update_hud(item_data)
	else:
		return

func on_animation_finish(anim_name):
	match anim_name:
		"unequip":
			is_equipped = false
		"equip":
			is_equipped = true
