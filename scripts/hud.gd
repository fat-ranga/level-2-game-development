extends Control

var item_ui
var health_ui
var display_ui
var slot_ui

func _enter_tree():
	item_ui = $Background/ItemUI
	health_ui = $Background/ItemUI
	display_ui = $Background/Display/ItemTexture
	slot_ui = $Background/Display/ItemSlot

func update_item_ui(item_data, item_slot):
	slot_ui.text = item_slot
	display_ui.texture = item_data["Image"]
	
	if item_data["Name"] == "Unarmed":
		item_ui.text = item_data["Name"]
		return
	
	item_ui.text = item_data["Name"] + ": " + item_data["Ammo"] + "/" + item_data["ExtraAmmo"]

