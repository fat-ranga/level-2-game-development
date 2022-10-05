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

func update_ammo(action="refresh"):
	var item_data = {
		"Name": item_name,
		"Image": item_image
	}
	
	item_manager.update_hud(item_data)

func on_animation_finish(anim_name):
	match anim_name:
		"Unequip":
			is_equipped = false
		"Equip":
			is_equipped = true
