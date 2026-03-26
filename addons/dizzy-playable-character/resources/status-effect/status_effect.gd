class_name StatusEffect
extends Resource
## Handles the creation of status effect instances. To be used with the [Status] resource to make
## changes to a [Character]'s stats or status.

## The signal to be emitted by status effect instances upon application. This signal is not emitted
## by this [StatusEffect] resource itself.
signal stack_applied(status_effect: StatusEffect)
## The signal to be emitted by status effect instances when they are ticked (updated). This signal
## is not emitted by this [StatusEffect] resource itself.
signal ticked(status_effect: StatusEffect)
## The signal to be emitted by status effect instances upon removal.This signal is not emitted by
## this [StatusEffect] resource itself.
signal stack_removed(status_effect: StatusEffect)

## The type of status effect instance. A status effect's type determines how [Status] resources
## will handle them.
enum StatusEffectType {
	## General type status effect.
	TYPE_GENERAL,
	## Buff (positive) type status effect.
	TYPE_BUFF,
	## Debuff (negative) type status effect.
	TYPE_DEBUFF
}
## Determines how status effect instance duration is tracked and updated.
enum StatusEffectDurationMode {
	## Infinte duration mode. Status effect duration is infinite and can only be removed manually.
	MODE_INFINITE,
	## Ignore new stack mode. Status effect duration will not be modified when this status
	## effect is stacked.
	MODE_IGNORE_NEW_STACK,
	## Per-stack mode. Status effect duration is per stack.
	MODE_PER_STACK,
	## Queue stack mode. Status effect duration is the sum of the duration of all stacks.
	MODE_QUEUE_STACK,
	## Reset on new stack mode. Status effect duration is reset when this status effect is stacked.
	MODE_RESET_ON_NEW_STACK
}

# Info

@export_category("Info")
## The name of this [StatusEffect].
@export var name: String
## The icon for this [StatusEffect].
@export var icon: Texture2D
## The simple description for this [StatusEffect].
@export_multiline var brief_description: String
## The detailed description for this [StatusEffect].
@export_multiline var long_description: String

# Functionality

@export_category("Functionality")
## The type of status effect instance this [StatusEffect] will create.
@export var status_effect_type: StatusEffectType
## The amount of time (in seconds) that this status effect lasts for.
@export var duration: float
## The duration mode that status effect instances will use (See [enum StatusEffectDurationMode]).
@export var duration_mode: StatusEffectDurationMode
## An array holding all [StatusEffectComponent]s of this [StatusEffect].
@export var components: Array[StatusEffectComponent]

## Returns a status effect instance from this [StatusEffect] resource.
func get_status_effect_instance() -> Dictionary:
	var instance = {
		"metadata" 		 : {
			"name"				: name,
			"icon"				: icon,
			"brief_description"	: brief_description,
			"long_description"	: long_description
		},

		"functional"	 : {
			"type"				: status_effect_type,
			"duration"			: duration,
			"duration_mode"		: duration_mode,
			"components"		: components,		
		},

		"affected_actor" : null,
		# "attached_stats" : _stats,
		"stacks"		 : [],

		"on_stack_applied"		 : Signal(self, "stack_applied"),
		"on_ticked"		 		 : Signal(self, "ticked"),
		"on_stack_removed"		 : Signal(self, "stack_removed")
	}

	return instance

## Returns the remaining duration for the given [param status_effect_instance] accordng to its
## [enum StatusEffectDurationMode].
static func get_remaining_duration_status_effect_instance(status_effect_instance: Dictionary) -> int:
	match status_effect_instance["functional"]["duration_mode"]:
		StatusEffectDurationMode.MODE_INFINITE:
			return 0
		StatusEffectDurationMode.MODE_PER_STACK:
			var max = -1
			for stack in status_effect_instance["stacks"]:
				max = max(stack, max)
			return max
		StatusEffectDurationMode.MODE_QUEUE_STACK:
			var sum = 0
			for stack in status_effect_instance["stacks"]:
				sum += stack
			return sum
		_:
			# return the stack closest to 0
			var min = 999999
			for stack in status_effect_instance["stacks"]:
				min = min(stack, min)
			return min