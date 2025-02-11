class_name MagicAttackComponent extends ActionComponent

@export var primary_spell: Spell
@export var secondary_spell: Spell

@onready var cooldown_timer = $Timer

var is_on_cooldown: bool = false

func _do_primary_action(target_global_position: Vector3):
	if is_on_cooldown:
		return
	
	cooldown_timer.start(primary_spell.cooldown)
	is_on_cooldown = true
	cooldown_timer.timeout.connect(_on_cooldown_timer_timeout)
	
	for i in range(primary_spell.projectile_count):	
		var normalized_direction = (get_random_pos_in_sphere(primary_spell.projectile_spread) + (target_global_position - self.global_position)).normalized()
		
		var projectile_instance = primary_spell.projectile_scene.instantiate()
		projectile_instance.spell = primary_spell
		projectile_instance.on_hit.connect(_on_spell_projectile_hit)
		owner.owner.add_child(projectile_instance)
		
		projectile_instance.global_position = self.global_position
		projectile_instance.speed = primary_spell.speed
		projectile_instance.normalized_direction = normalized_direction
		
		if primary_spell.projectile_count == 1:
			return
		
		if primary_spell.projectile_fire_delay == 0:
			continue
		
		await get_tree().create_timer(primary_spell.projectile_fire_delay).timeout
func _do_secondary_action(target_global_position: Vector3):
	if is_on_cooldown:
		return
	
	cooldown_timer.start(secondary_spell.cooldown)
	is_on_cooldown = true
	cooldown_timer.timeout.connect(_on_cooldown_timer_timeout)
	
	for i in range(secondary_spell.projectile_count):	
		var normalized_direction = (get_random_pos_in_sphere(secondary_spell.projectile_spread) + (target_global_position - self.global_position)).normalized()
		
		var projectile_instance = secondary_spell.projectile_scene.instantiate()
		projectile_instance.spell = secondary_spell
		projectile_instance.on_hit.connect(_on_spell_projectile_hit)
		owner.owner.add_child(projectile_instance)
		
		projectile_instance.global_position = self.global_position
		projectile_instance.speed = secondary_spell.speed
		projectile_instance.normalized_direction = normalized_direction
		
		if secondary_spell.projectile_count == 1:
			return
		
		if secondary_spell.projectile_fire_delay == 0:
			continue
		
		await get_tree().create_timer(secondary_spell.projectile_fire_delay).timeout

func _on_cooldown_timer_timeout():
	is_on_cooldown = false
	cooldown_timer.stop()
	cooldown_timer.timeout.disconnect(_on_cooldown_timer_timeout)

func _on_spell_projectile_hit(projectile_instance: ProjectileInstance, body: Node):
	if body.has_node("DamageReceiverComponent"):
		deal_damage(body.get_node("DamageReceiverComponent"), projectile_instance.spell.damage)
	if body.has_node("AffectorManagerComponent"):
		if projectile_instance.spell.affector_scene == null:
			return
		apply_affectors(body.get_node("AffectorManagerComponent"), projectile_instance.spell.affector_scene.instantiate())

func deal_damage(damage_receiver_component: DamageReceiverComponent, damage: int):
	damage_receiver_component.damage(damage)
func apply_affectors(affector_manager_component: AffectorManagerComponent, affector: Affector):
	affector_manager_component.add_affector(affector)

func get_random_pos_in_sphere (radius: float) -> Vector3:
	var x1 = randf_range(-1, 1)
	var x2 = randf_range(-1, 1)

	while x1*x1 + x2*x2 >= 1:
		x1 = randf_range(-1, 1)
		x2 = randf_range(-1, 1)

	var random_pos_on_unit_sphere = Vector3 (
			2 * x1 * sqrt (1 - x1 * x1 - x2 * x2),
			2 * x2 * sqrt (1 - x1 * x1 - x2 * x2),
			1 - 2 * (x1 * x1 + x2 * x2))

	return random_pos_on_unit_sphere * randf_range(0, radius)
