class_name Status
extends Resource
## Holds data pertaining to the status (health, status effects, damage) of a [Character].

## Emitted when [member max_health] is modified.
signal max_health_modified(old: int, new: int)
## Emitted when [member health] is modified.
signal health_modified(old: int, new: int)

## Emitted when [method heal] is called.
signal healed(heal_instance: HealInstance)

## Emitted before damage is applied to this [Status] resource. Supplies signal
## [param interrupt_callback] (see [signal interrupt_damage] for usage).
signal about_to_be_damaged(damage_instance: DamageInstance, interrupt_callback: Signal)
## The interrupt signal to be emitted by receivers of the [signal about_to_be_damaged] signal.
## This signal is not emitted by this [Status] resource itself.
signal interrupt_damage(interrupted: bool)
## Emitted when damage is applied to this [Status] resource while [member is_immune] is true.
signal damaged_immune(damage_instance: DamageInstance)
## Emitted when damage is interrupted.
signal damage_interrupted(damage_instance: DamageInstance)
## Emitted when damage is successfully applied to this [Status] resource.
signal damaged(damage_instance: DamageInstance)

## Emitted when [member health] is equal to or less than zero.
signal died
## Emitted when [method revive] is called.
signal revived

## Emitted when a status effect instance is applied to this [Status] resource.
signal status_effect_applied(status_effect_instance: Dictionary)
## Emitted when a stack is applied to an existing status effect instance.
signal status_effect_stack_applied(status_effect_instance: Dictionary)
## Emitted when a status effect instance is ticked.
signal status_effect_ticked(status_effect_instance: Dictionary)
## Emitted when a stack is removed from an existing status effect instance.
signal status_effect_stack_removed(status_effect_instance: Dictionary)
## Emitted when a status effect instance is removed from this [Status] resource.
signal status_effect_removed(status_effect_instance: Dictionary)
## Emitted when a debuff status effect application is resisted.
signal resisted_debuff
## Emitted when a buff status effect removal is resisted.
signal retained_buff

# Health

## The maximum amount of health.
var max_health: int:
	set(value):
		var old = max_health
		max_health = value
		max_health_modified.emit(old, max_health)
## The current amount of health.
var health: int:
	set(value):
		if is_dead:
			return
		var old = health
		if old == value:
			return
		if value > max_health:
			value = max_health
		elif value <= 0:
			value = 0
			die()
		health = value
		health_modified.emit(old, health)
## If true, no damage of any kind can be taken.
var is_immune: bool = false:
	set(value):
		if is_dead:
			return
		is_immune = value
## If true, this [Status] resource is "dead". no damage, healing, nor status effects can be applied
## unless [method revive] is called.
var is_dead: bool = false

# Status Effects

## Holds all status effect instances by their name. See [StatusEffect] for details.
var status_effects: Dictionary = {}

# Modifiers

## The percent of damage to be resisted.
var damage_resistance: float = 0.00
## The percent chance for a debuff application to be resisted.
var debuff_resistance: float = 0.00
## The percent chance for a buff removal to be resisted.
var buff_retention: float = 0.00

## Applies damage (defined with [DamageInstance]) to this [Status] resource.
## See [DamageInstance] for details.
func damage(damage_instance: DamageInstance):
	if is_dead:
		return
	var damage_negated = int((damage_instance.base_damage * damage_resistance) + 0.5)
	var true_damage = damage_instance.base_damage - damage_negated + damage_instance.additional_damage
	var final_damage_instance = damage_instance.duplicate_instance()
	final_damage_instance.base_damage = true_damage
	
	if final_damage_instance.can_dodge or final_damage_instance.can_parry:
		var interrupt_callback = Signal(interrupt_damage)
		about_to_be_damaged.emit(final_damage_instance, interrupt_callback)
		var interrupted = await interrupt_callback
		if interrupted:
			damage_interrupted.emit(final_damage_instance)
			return
	else:
		about_to_be_damaged.emit(final_damage_instance, null)
	
	if is_immune:
		damaged_immune.emit(final_damage_instance)
		return
	
	health -= true_damage
	damaged.emit(final_damage_instance)
## Applies health (defined with [HealInstance]) to this [Status] resource.
## See [HealInstance] for details.
func heal(heal_instance: HealInstance):
	if is_dead:
		return
	
	health += heal_instance.heal
	healed.emit(heal_instance)
func revive(recover_health: int):
	if not is_dead:
		return
	
	is_dead = false
	health = recover_health
	revived.emit()

func die():
	if is_dead:
		return
	
	is_dead = true
	died.emit()

## Applies a status effect instance to this [Status] resource. if the given [StatusEffect] type
## is already applied, this method will add a stack to that status effect instance.
## Takes [param status_effect] for the [StatusEffect] type (see [StatusEffect] for details).
## Takes [param stacks] for the number of stacks to apply.
## Takes [param ignore_debuff_resistance] where if true the [member debuff_resistance] value is
## ignored.
func apply_status_effect(status_effect: StatusEffect, stacks: int = 1, ignore_debuff_resistance: bool = false):
	if is_dead:
		return

	var instance = status_effect.get_status_effect_instance()
	var status_effect_name = instance["metadata"]["name"]

	if not ignore_debuff_resistance:
		if instance["functional"]["type"] == StatusEffect.StatusEffectType.TYPE_DEBUFF:
			var resisted = _handle_debuff_resistance()
			if resisted:
				return

	for i in range(stacks):
		# var combined = _handle_combination(instance)
		# if combined:
		# 	instance = combined

		if status_effects.has(status_effect_name):
			_add_stacks_to_status_effect(status_effects[status_effect_name], 1)
			continue
			
		status_effects[status_effect_name] = instance
		#instance["affected_character"] = _character
		status_effect_applied.emit(instance)
		_add_stacks_to_status_effect(status_effects[status_effect_name], 1)

		for component in instance["functional"]["components"]:
			component.apply(instance, instance["affected_character"])

func _add_stacks_to_status_effect(status_effect_instance: Dictionary, stacks: int):
	var stacks_array = status_effect_instance["stacks"]
	var duration = status_effect_instance["functional"]["duration"]
	for i in range(stacks):
		stacks_array.append(duration)
		
		if status_effect_instance["functional"]["duration_mode"] == StatusEffect.StatusEffectDurationMode.MODE_RESET_ON_NEW_STACK:
			for j in range(stacks_array.size()):
				stacks_array[j] = duration
		
		status_effect_stack_applied.emit(status_effect_instance)
func _tick_status_effect(status_effect_instance: Dictionary):
	var stacks_array = status_effect_instance["stacks"]

	for component in status_effect_instance["functional"]["components"]:
		component.tick(status_effect_instance, status_effect_instance["affected_character"])

	# tick status effect if it is meant to be infinite.
	if status_effect_instance["functional"]["duration"] == 0:
		status_effect_ticked.emit(status_effect_instance)
		return
	
	# update individual stack counters UNLESS _duration_mode == MODE_QUEUE_STACK OR _duration_turns == 0
	if (status_effect_instance["functional"]["duration_mode"] == StatusEffect.StatusEffectDurationMode.MODE_QUEUE_STACK):
		stacks_array[0] -= 1
	else:
		for i in range(stacks_array.size()):
			stacks_array[i] -= 1
	
	#status_effect_instance["on_ticked"].emit(status_effect_instance)
	status_effect_ticked.emit(status_effect_instance)

	var stacks_to_end = []
	for i in range(stacks_array.size()):
		if stacks_array[i] <= 0:
			stacks_to_end.append(i)
	for i in stacks_to_end:
		if stacks_array.is_empty():
			return
		_end_status_effect_stack(status_effect_instance, stacks_to_end[i])
func _end_status_effect_stack(status_effect_instance: Dictionary, stack_index: int):
	var affected_character = status_effect_instance["affected_character"]
	var stacks_array = status_effect_instance["stacks"]
	var components_array = status_effect_instance["functional"]["components"]

	match status_effect_instance["functional"]["duration_mode"]:
		StatusEffect.StatusEffectDurationMode.MODE_INFINITE:
			return
		StatusEffect.StatusEffectDurationMode.MODE_PER_STACK:
			_remove_stack_from_status_effect(status_effect_instance, stack_index)

			if not stacks_array.is_empty():
				return
			
			for component in components_array:
				component.end(status_effect_instance, affected_character)
		StatusEffect.StatusEffectDurationMode.MODE_QUEUE_STACK:
			_remove_stack_from_status_effect(status_effect_instance, stack_index)

			if not stacks_array.is_empty():
				return
			
			for component in components_array:
				component.end(status_effect_instance, affected_character)
		_:
			for i in range(stacks_array.size() - 1, -1, -1):
				_remove_stack_from_status_effect(status_effect_instance, i)
			
			for component in components_array:
				component.end(status_effect_instance, affected_character)
func _remove_stack_from_status_effect(status_effect_instance: Dictionary, stack_index: int):
	var stacks_array = status_effect_instance["stacks"]
	stacks_array.remove_at(stack_index)
	status_effect_stack_removed.emit(status_effect_instance)
	
	if stacks_array.size() > 0:
		return
		
	_clear_status_effect(status_effect_instance)

## Removes a status effect instance from this [Status] resource.
func remove_status_effect(status_effect_instance: Dictionary, stacks: int = 1, ignore_bfrt: bool = false):
	var status_effect_name = status_effect_instance["metadata"]["name"]

	if not status_effects.has(status_effect_name):
		return
	
	var status_effect = status_effects[status_effect_name]
	var stacks_array = status_effect["stacks"]
	
	for i in range(stacks):
		if not ignore_bfrt:
			if status_effect["functional"]["type"] == StatusEffect.StatusEffectType.TYPE_BUFF:
				var retained = _handle_buff_retention()
				if retained:
					continue
		
		stacks_array.remove_at(stacks_array.size() - 1)

func _clear_status_effect(status_effect_instance: Dictionary):
	var status_effect_name = status_effect_instance["metadata"]["name"]
	if not status_effects.has(status_effect_name):
		return
	for i in range(status_effects[status_effect_name]["stacks"].size() - 1, -1, -1):
		_remove_stack_from_status_effect(status_effects[status_effect_name], i)
	status_effect_removed.emit(status_effects[status_effect_name])
	status_effects.erase(status_effect_name)
func _clear_all_status_effects():
	for status_effect_name in status_effects.keys():
		var status_effect = status_effects[status_effect_name]
		_clear_status_effect(status_effect)
		status_effect_removed.emit(status_effect)
	status_effects.clear()

func _handle_debuff_resistance() -> bool:
	var roll = randf()
	if roll < debuff_resistance:
		resisted_debuff.emit()
		return true
	return false
func _handle_buff_retention() -> bool:
	var roll = randf()
	if roll < buff_retention:
		retained_buff.emit()
		return true
	return false

# func _handle_combination(status_effect_instance: Dictionary):
# 	# search for any CombineRules first
# 	var combine_rules = status_effect_instance["functional"]["components"].filter(func(component): return component is CombineRule)
# 	if combine_rules.size() == 0:
# 		return null

# 	# if any CombineRule components found, see if any matching input status effect is active
# 	var matching_active_effects = []
# 	for rule in combine_rules:
# 		for rule_effect_name in rule.get_combination_rules().keys():
# 			if not status_effects.has(rule_effect_name):
# 				continue
			
# 			matching_active_effects.append(status_effects[rule_effect_name])
# 	if matching_active_effects.size() == 0:
# 		return null

# 	# combinations should happen with the last applied APPLICABLE status effect, usually the active status effect with
# 	# the greatest duration remaining.
# 	var last_applied_status_effect = matching_active_effects[0]

# 	for matching_active_effect in matching_active_effects:
# 		if StatusEffect.get_remaining_duration_status_effect_instance(matching_active_effect) > StatusEffect.get_remaining_duration_status_effect_instance(last_applied_status_effect):
# 			last_applied_status_effect = matching_active_effect

# 	# remove the other effect
# 	remove_status_effect(last_applied_status_effect, 1)

# 	var combination_result
# 	for rule in combine_rules:
# 		for rule_effect_name in rule.get_combination_rules().keys():
# 			if rule_effect_name == last_applied_status_effect["metadata"]["name"]:
# 				combination_result = rule.get_combination_rules()[last_applied_status_effect["metadata"]["name"]].get_status_effect_instance()
# 				break

# 	return combination_result

func tick_debuffs():
	for status_effect_name in status_effects.keys():
		var status_effect_instance = status_effects[status_effect_name]
		if status_effect_instance["functional"]["type"] != StatusEffect.StatusEffectType.TYPE_DEBUFF:
			continue
		_tick_status_effect(status_effect_instance)
func tick_general():
	for status_effect_name in status_effects.keys():
		var status_effect_instance = status_effects[status_effect_name]
		if status_effect_instance["functional"]["type"] != StatusEffect.StatusEffectType.TYPE_GENERAL:
			continue
		_tick_status_effect(status_effect_instance)
func tick_buffs():
	for status_effect_name in status_effects.keys():
		var status_effect_instance = status_effects[status_effect_name]
		if status_effect_instance["functional"]["type"] != StatusEffect.StatusEffectType.TYPE_BUFF:
			continue
		_tick_status_effect(status_effect_instance)