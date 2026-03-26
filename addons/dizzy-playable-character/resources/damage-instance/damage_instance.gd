class_name DamageInstance
extends Resource

## responsible for communicating any information about any source of damage to any Status resource.

## The originator of the damage.
var source: Node

@export_subgroup("Interruption")
## Can this damage be dodged and negated?
@export var can_dodge: bool = false
## Can this damage be parried and negated?
@export var can_parry: bool = false
## The window of time where the damage can be interrupted.
@export var time_to_interrupt: float = 0.0

@export_subgroup("Damage")
## The amount of damage to apply before resistances and other status effects.
@export var base_damage: int = 0
## Is this critical damage?
@export var is_crit: bool = false
## The amount of additional damage to apply after resistances and other status effects.
@export var additional_damage: int = 0

@export_subgroup("Visuals")
## Spawn a status number when consumed?
@export var spawn_status_number: bool
