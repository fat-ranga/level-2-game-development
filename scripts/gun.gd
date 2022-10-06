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
export var ammo_in_magazine = 15
export var extra_ammo = 30
onready var magazine_size = ammo_in_magazine

export var damage = 10
export var fire_rate = 1.0

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
	if not is_reloading:
		if ammo_in_magazine > 0:
			if not is_firing:
				is_firing = true
				animation_player.get_animation("Fire").loop = true # So we can set it to false later.
				animation_player.play("Fire", -1.0, fire_rate)
			return
		elif is_firing:
			fire_stop() # If we have no ammo, don't fire. 

func fire_stop():
	is_firing = false
	animation_player.get_animation("Fire").loop = false

# Will be called from the animation track.
func fire_bullet():
	muzzle_flash_animation_player.play("scale_flash")
	update_ammo("consume")
	
	ray.force_raycast_update() # Updates collision information.
	
	# If we hit something, spawn a hit effect at that location.
	if ray.is_colliding():
		var impact = Global.instantiate_node(impact_effect, ray.get_collision_point())

func reload():
	if ammo_in_magazine < magazine_size and extra_ammo > 0:
		is_firing = false
		
		animation_player.play("Reload", -1.0, reload_speed)
		is_reloading = true

# Equip/unequip cycle.
# NOTE: Make sure that there is always an animation playing, so that 
func equip():
	animation_player.play("Equip", -1.0, equip_speed)
	is_reloading = false # Otherwise we cannot fire our weapon.

func unequip():
	animation_player.play("Unequip", -1.0, unequip_speed)
	
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
		"Unequip":
			is_equipped = false
		"Equip":
			is_equipped = true
		"Reload":
			is_reloading = false
			update_ammo("reload")

func update_ammo(action="refresh", additional_ammo=0):
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
		"Name": item_name,
		"Image": item_image,
		"Ammo": str(ammo_in_magazine),
		"ExtraAmmo": str(extra_ammo)
	}
	
	item_manager.update_hud(item_data)

# Drops item on the ground by spawning a weapon pickup and deleting itself.
func drop_item():
	var pickup = Global.instantiate_node(item_pickup, global_transform.origin)
	pickup.apply_impulse(transform.basis.z, pickup.transform.basis.z * 10)
	
	# Copy values from current item into the item we're dropping.
	pickup.ammo_in_magazine = ammo_in_magazine
	pickup.extra_ammo = extra_ammo
	pickup.magazine_size = magazine_size
	
	queue_free() # Delete item currently held.
