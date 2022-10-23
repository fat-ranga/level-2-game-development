extends Area

export(int) var ammo = 10

func _on_AmmoPickup_body_entered(body):
	if body.is_in_group("Player"):
		var result = body.item_manager.add_ammo(ammo)
		
		# If the ammo box is picked up, delete it.
		if result:
			queue_free()
