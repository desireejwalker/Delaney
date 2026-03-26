class_name PlayableCharacterComponent
extends Node3D
## A parent class for all components of [PlayableCharacter] nodes.

## Emitted when this [PlayableCharacterComponent] is initialized. Emit this signal after any
## additional statements in overridden implementations of [method initialize]
signal initialized

## If true, this component is active and will process.
var is_active: bool = false

# Components

## The parent [PlayableCharacter].
var playable_character: PlayableCharacter

## This method should be overriden. It will be called by the parent [PlayableCharacter] once it is
## initialized. Ensure that super() is called at the ends of any overriden implementations. 
func initialize(playable_character: PlayableCharacter):
	self.playable_character = playable_character
	is_active = true
	initialized.emit()