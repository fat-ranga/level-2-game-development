extends RigidBody

# Item parameters that will be transferred if this weapon is picked up.
export var item_name = "Item"
export(String, "Any", "Melee", "Primary", "Secondary", "Grenade", "Special") var item_slot_type = "Any"
export var ammo_in_magazine = 5
export var extra_ammo = 10
onready var magazine_size = ammo_in_magazine

func _ready():
	connect("sleeping_state_changed", self, "on_sleeping")

# Rigidbody is turned into a static body after it's been inactive for some time.
func on_sleeping():
	mode = MODE_STATIC

func get_item_pickup_data():
	return {
		"name": item_name,
		"slot_type": item_slot_type,
		"ammo": ammo_in_magazine,
		"extra_ammo": extra_ammo,
		"magazine_size": magazine_size
	}
