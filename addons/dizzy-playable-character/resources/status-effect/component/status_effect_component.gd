class_name StatusEffectComponent
extends Resource
## Parent class responsible for interfacing with components of status effect instances from
## [StatusEffect].

## This method should be overridden. Should be called by the [Status] resource when the status
## effect instance is applied.
func apply(status_effect: Dictionary, affected_character: Character):
	pass
## This method should be overridden. Should be called by the [Status] resource when the status
## effect instance is ticked (updated).
func tick(status_effect: Dictionary, affected_character: Character):
	pass
## This method should be overridden. Should be called by the [Status] resource when the status
## effect instance is removed.
func end(status_effect: Dictionary, affected_character: Character):
	pass