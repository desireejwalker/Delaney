# class_name DamageInstance
extends Resource


@export var initialDamageAmount: int = 1
@export var debuff: DebuffInstance

func _init(initialDamageAmount: int, debuff: DebuffInstance):
	self.initialDamageAmount = initialDamageAmount
	self.debuff = null
