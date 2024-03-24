class_name HammerType extends Resource

@export var scene: PackedScene

@export_category("Lore")
@export var name: String
@export_multiline var tooltip: String

@export_category("Attributes")
@export var damage: int = 1 ## Damage applied on hit.
@export var attack_speed: int = 1 ## Attacks/sec.
@export_range(0, 1) var critical_chance: float = 0.1 ## Percent chance to double damage on hit.
@export var use_auto_aim: bool
