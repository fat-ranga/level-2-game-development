extends Item

# References.
var animation_player

# Rigidbody version for picking up/dropping.
export(PackedScene) var item_pickup

# The offset of the weapon from the hand when picked up.
export var equip_position = Vector3.ZERO

# Weapon states.
var is_firing = false
var is_reloading = false

# Gun parameters.
export var is_automatic = true
export var ammo_in_magazine = 15
export var extra_ammo = 30
onready var magazine_size = ammo_in_magazine

export var damage = 10
export var fire_rate = 1.0 # Non-automatic weapons also consider this.
export var projectiles_per_shot = 1
export var randomness = 0.5

# Effects.
export(PackedScene) var impact_effect
export(NodePath) var muzzle_flash_path
onready var muzzle_flash = get_node(muzzle_flash_path)
onready var muzzle_flash_animation_player = get_node(str(muzzle_flash_path) + "/AnimationPlayer")

# Optional.
export var equip_speed = 1.0
export var unequip_speed = 1.0
export var reload_speed = 1.0

func fire():
	if is_automatic:
		if not is_reloading:
			if ammo_in_magazine > 0:
				if not is_firing:
					is_firing = true
					animation_player.get_animation("fire").loop = true # So we can set it to false later.
					animation_player.play("fire", -1.0, fire_rate)
				return
			elif is_firing:
				fire_stop() # If we have no ammo, don't fire. 
	else:
		if not is_reloading:
			if ammo_in_magazine > 0:
				if not is_firing:
					is_firing = true
					#animation_player.get_animation("Fire").loop = true # So we can set it to false later.
					animation_player.play("fire", -1.0, fire_rate)
				return
			elif is_firing:
				fire_stop() # If we have no ammo, don't fire. 

func fire_stop():
	is_firing = false
	animation_player.get_animation("fire").loop = false

# Will be called from the animation track.
func fire_bullet():
	muzzle_flash_animation_player.play("scale_flash")
	update_ammo("consume")
	
	ray.force_raycast_update() # Updates collision information.
	
	# If we hit something, spawn a hit effect at that location.
	if ray.is_colliding():
		var impact
		# Spawn the hit effect a little bit away from the surface to reduce clipping.
		var impact_position = (ray.get_collision_point()) + (ray.get_collision_normal() * 0.2)
		impact = Global.instantiate_node(impact_effect, impact_position)
		# TODO: delete these, or better, use a pool instead

func reload():
	if ammo_in_magazine < magazine_size and extra_ammo > 0:
		is_firing = false
		
		animation_player.play("reload", -1.0, reload_speed)
		is_reloading = true

# Equip/unequip cycle.
# NOTE: Make sure that there is always an animation playing, so that 
func equip():
	animation_player.play("equip", -1.0, equip_speed)
	is_reloading = false # Otherwise we cannot fire our weapon.

func unequip():
	animation_player.play("unequip", -1.0, unequip_speed)
	
func is_equip_finished():
	if is_equipped:
		return true
	else:
		return false

func is_unequip_finished():
	if is_equipped:
		return false
	else:
		return true

# Called when the node enters the scene tree for the first time.
func _ready():
	animation_player = $AnimationPlayer
	animation_player.connect("animation_finished", self, "on_animation_finish")
	
func on_animation_finish(anim_name):
	match anim_name:
		"unequip":
			is_equipped = false
		"equip":
			is_equipped = true
		"reload":
			is_reloading = false
			update_ammo("reload")

func update_ammo(action="refresh", additional_ammo=0, update_hud=true):
	match action:
		"consume":
			ammo_in_magazine -= 1
		"reload":
			var ammo_needed = magazine_size - ammo_in_magazine
			
			if extra_ammo > ammo_needed:
				ammo_in_magazine = magazine_size
				extra_ammo -= ammo_needed
			else:
				ammo_in_magazine += extra_ammo
				extra_ammo = 0
		"add":
			extra_ammo += additional_ammo
	
	var item_data = {
		"name": item_name,
		"image": item_image,
		"slot_type": item_slot_type,
		"ammo": str(ammo_in_magazine),
		"extra_ammo": str(extra_ammo)
	}
	
	# This is in case we are updating the data of an item that isn't currently in hand.
	if update_hud:
		item_manager.update_hud(item_data)
	else:
		return

# Drops item on the ground by spawning a weapon pickup and deleting itself.
func drop_item():
	var pickup = Global.instantiate_node(item_pickup,  global_transform.origin)
	pickup.apply_impulse(-player.global_transform.basis.z, player.global_transform.basis.z * 5)
	
	# Copy values from current item into the item we're dropping.
	pickup.ammo_in_magazine = ammo_in_magazine
	pickup.extra_ammo = extra_ammo
	pickup.magazine_size = magazine_size
	
	queue_free() # Delete item currently held.
