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

export var damage = 15
export var fire_rate = 1.0 # Non-automatic weapons also consider this.
export var projectiles_per_shot = 5
export var projectile_speed = 4.0
export var randomness = 0.5
export var raycast_distance = 5 # Distance beyond which we generate projectiles when fired.

# Effects.
export(PackedScene) var blood_impact
export(PackedScene) var dust_impact
export(PackedScene) var bullet_projectile
export(NodePath) var muzzle_flash_path
export(NodePath) var muzzle_path
onready var muzzle_flash = get_node(muzzle_flash_path)
onready var muzzle_flash_animation_player = get_node(str(muzzle_flash_path) + "/AnimationPlayer")
onready var muzzle = get_node(muzzle_path)

# Optional.
export var equip_speed = 1.0
export var unequip_speed = 1.0
export var reload_speed = 1.0

# Pool of projectiles, these are added and deleted when a gun is fired.
var projectiles = []
# So we can get the correct last position for each bullet.
var projectile_index = 0
# So that the projectile isn't clipping with the gun when spawned.
var projectile_offset = 3.5

# Same as with the projectile pool.
var impact_effects = []


func _ready():
	# Apparently this allows random functions to work.
	randomize()
	
	animation_player = $AnimationPlayer
	animation_player.connect("animation_finished", self, "on_animation_finish")
	muzzle_flash.visible = false

func _physics_process(delta):
	process_projectiles(delta)
	process_impact_effects(delta)

func process_projectiles(delta):
	for bullet in projectiles:
		# Get the last position of the bullet, from which we can draw the ray.
		bullet.last_position = bullet.translation
		
		# Delete bullet if it's existed for too long.
		bullet.lifetime -= delta
		if bullet.lifetime < 0:
			# Delete the bullet and remove it from the array.
			bullet.queue_free()
			projectiles.erase(bullet)
		
		bullet.global_translate(-bullet.transform.basis.z * projectile_speed)
		var space_state = get_world().direct_space_state
		
		var collision = space_state.intersect_ray(bullet.last_position, bullet.global_transform.origin, [self])
		if collision:
			var impact
			# Spawn the hit effect a little bit away from the surface to reduce clipping.
			var impact_position = (collision.position) + (collision.normal * 0.2)
			var hit = collision.collider
			
			# Check if we hit an enemy, then damage them. Spawn the correct impact effect.
			if hit.is_in_group("Enemy"):
				hit.damage(damage)
				var new_impact = Global.instantiate_node(blood_impact, impact_position)
				impact_effects.append(new_impact)
			else:
				var new_impact = Global.instantiate_node(dust_impact, impact_position)
				impact_effects.append(new_impact)
			# Delete the bullet and remove it from the array.
			bullet.queue_free()
			projectiles.erase(bullet)

func process_impact_effects(delta):
	for effect in impact_effects:
	# Delete effect if it's existed for too long.
		effect.lifetime -= delta
		if effect.lifetime < 0:
			# Delete the effect and remove it from the array.
			effect.queue_free()
			impact_effects.erase(effect)

# Will be called from the animation track.
func fire_bullet():
	muzzle_flash.visible = true
	muzzle_flash_animation_player.play("scale_flash")
	update_ammo("consume")
	
	# Reset the rotation of the ray, since we randomise it later.
	ray.rotation = Vector3.ZERO
	
	ray.force_raycast_update() # Updates collision information.
	
	# If we hit something, do stuff.
	if ray.is_colliding():
		# Determine whether we should spawn an actual projectile for this bullet.
		var origin = ray.global_transform.origin
		var collision_point = ray.get_collision_point()
		var distance = origin.distance_to(collision_point)
		
		if distance > raycast_distance:
			for i in projectiles_per_shot:
				var projectile = Global.instantiate_node(bullet_projectile, muzzle.global_transform.origin)
				projectile.look_at(collision_point, Vector3.UP)
				
				# Last position is by default at the end of the gun.
				projectile.last_position = muzzle.global_transform.origin
				
				# Add a bit of randomisation.
				projectile.rotation += Vector3(rand_range(randomness, -randomness),
				rand_range(randomness, -randomness),
				rand_range(randomness, -randomness))
				
				# Make the projectile visible after the offset has been applied.
				projectile.global_translate(-projectile.transform.basis.z * projectile_offset)
				projectile.visible = true
				
				projectiles.append(projectile)
		else:
			# Update the raycast instead of spawning a projectile.
			for i in projectiles_per_shot:
				# Add a bit of randomisation.
				ray.rotation += Vector3(rand_range(randomness, -randomness),
				rand_range(randomness, -randomness),
				rand_range(randomness, -randomness))
				
				ray.force_raycast_update() # Updates collision information.
				
				# Reset the rotation of the ray, after getting collision information.
				ray.rotation = Vector3.ZERO
				
				# If any of the rays hit something, do stuff.
				if ray.is_colliding():
					var impact
					# Spawn the hit effect a little bit away from the surface to reduce clipping.
					var impact_position = (ray.get_collision_point()) + (ray.get_collision_normal() * 0.2)
					var hit = ray.get_collider()
					if hit.is_in_group("Enemy"):
						hit.damage(damage)
						impact = Global.instantiate_node(blood_impact, impact_position)
					else:
						impact = Global.instantiate_node(dust_impact, impact_position)
	else:
		for i in projectiles_per_shot:
			# Set the point the bullet looks at to a point the ray is facing.
			var far_away_point = ray.global_transform.origin + -ray.global_transform.basis.z * 100
			var projectile = Global.instantiate_node(bullet_projectile, muzzle.global_transform.origin)
			projectile.look_at(far_away_point, Vector3.UP)
			
			# Last position is by default at the end of the gun.
			projectile.last_position = muzzle.global_transform.origin
			
			# Add a bit of randomisation.
			projectile.rotation+= Vector3(rand_range(randomness, -randomness),
			rand_range(randomness, -randomness),
			rand_range(randomness, -randomness))
			
			# Make the projectile visible after the offset has been applied.
			projectile.global_translate(-projectile.transform.basis.z * projectile_offset)
			projectile.visible = true
			
			projectiles.append(projectile)

func fire():
	# Basically loop the firing animation if the weapon is automatic, otherwise don't.
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
	is_reloading = false # Might as well.
	
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
