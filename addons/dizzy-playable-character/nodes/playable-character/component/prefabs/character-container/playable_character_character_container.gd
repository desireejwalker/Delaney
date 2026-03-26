class_name PlayableCharacterCharacterContainer
extends PlayableCharacterComponent
## A [PlayableCharacter] component responsible for managing one or more [Character]s.

## Emitted when a new character has been added to this [PlayableCharacterCharacterContainer].
signal character_added(character: Character)
## Emitted when a character has been removed from this [PlayableCharacterCharacterContainer].
signal character_removed(character: Character)
## Emitted when [method PlayableCharacterCharacterContainer.clear_characters] is called.
signal characters_cleared()

## Emitted when the [member current_character] changes.
signal current_character_changed(old: Character, new: Character)
## Emitted when an attempt to change [member current_character] fails.
signal character_switch_failed

# Characters

## If true, this [PlayableCharacterCharacterContainer] can modify
## [member PlayableCharacterCharacterContainer.current_character].
var can_switch_characters: bool = false
## The internal dictionary that holds [Character]s by their internal name as a key.
var internal_characters: Dictionary[StringName, Character]
## The currently active character.
var current_character: Character

## The array of [Character]s that this [PlayableCharacterCharacterContainer] is responsible for.
## should only be modified in the inspector.
@export var characters: Array[Character]
## The maximum allowed character count for this [PlayableCharacterCharacterContainer].
@export var max_character_count: int = 3

# Input

## If true, the player can switch characters manually using either discrete input (ex. number keys)
## or relative input (ex. scroll wheel).
@export var allow_player_input: bool
## if true, use discrete input instead of relative input.
@export var use_discrete_input: bool
## Holds the names of the input actions for discrete input. The index should match the character
## index.
@export var discrete_input_actions: Array[StringName]
## The name of the input action to switch to the next [Character].
@export var next_character_input_action: StringName
## The name of the input action to switch to the previous [Character].
@export var previous_character_input_action: StringName

## Initializes this [PlayableCharacterMover] component for use.
##
## Takes [param playable_character] for the parent [PlayableCharacter].
func initialize(playable_character: PlayableCharacter):
	_setup_characters()
	_setup_first_character()
	super(playable_character)

## Adds a [Character] to this [PlayableCharacterCharacterContainer].
## If this addition would exceed the 
## [member PlayableCharacterCharacterContainer.max_character_count], this method does nothing.
##
## Takes [param internal_name] as the key for the given [Character].
## Takes [param character] as the [Character] node to add.
func add_character(internal_name: StringName, character: Character):
	if internal_characters.keys().size() + 1 > max_character_count:
		return
	
	internal_characters[internal_name] = character
	character_added.emit(character)

## Removes a [Character] from this [PlayableCharacterCharacterContainer].
## If the given [param internal_name] is not found in this [PlayableCharacterCharacterContainer],
## nothing happens.
## Note: This method does not free the [Character]. listen to the [signal character_removed] for
## handling this. 
## 
## Takes [param internal_name] as the key for the [Character] to remove.
func remove_character(internal_name: StringName):
	if not is_active:
		return
	if not internal_characters.has(internal_name):
		return

	var character = internal_characters[internal_name]
	if current_character == character:
		current_character = null
	character_removed.emit(character)
	internal_characters.erase(character)

## Removes and frees all [Character]s from this [PlayableCharacterCharacterContainer].
func clear_characters():
	if not is_active:
		return
	for internal_name in internal_characters.keys():
		internal_characters[internal_name].queue_free()
	
	internal_characters = {}
	current_character = null
	characters_cleared.emit()

func _process(_delta: float) -> void:
	if not is_active:
		return
	_handle_switching_input()

# func get_next_alive_character_index() -> int:
# 	if all_characters_dead():
# 		return -1
	
# 	var next_character_index = -1
	
# 	var index = characters.find(current_character)
# 	while next_character_index == -1:
# 		index += 1
# 		if index >= characters.size():
# 			index = 0
# 		var next = characters[index]
# 		if next.get_character_status().is_dead():
# 			continue
# 		next_character_index = index
	
# 	return next_character_index

# func all_characters_dead() -> bool:
# 	for character in characters:
# 		if not character.get_character_status().is_dead():
# 			return false
	
# 	return true

func _setup_characters():
	for character in characters:
		add_character(character.data.internal_name, character)
		remove_child(character)
func _setup_first_character():
	current_character = internal_characters[internal_characters.keys()[0]]
	add_child(current_character)

func _handle_switching_input() -> bool:
	if not is_active:
		return false
	if not allow_player_input:
		return false

	if use_discrete_input:
		return _handle_discrete_input()
	return _handle_relative_input()

func _handle_discrete_input() -> bool:
	if not is_active:
		return false
	for i in range(discrete_input_actions.size()):
		if i >= internal_characters.keys().size():
			return false
		
		var action_name = discrete_input_actions[i]
		if not Input.is_action_just_pressed(action_name):
			continue
		
		var internal_name = internal_characters.keys()[i]
		
		if current_character == internal_characters[internal_name]:
			return false
		
		return handle_switch_to_character(internal_name)

	return false

func _handle_relative_input() -> bool:
	if not is_active:
		return false
	var current_index = internal_characters.keys().find(current_character.metadata.internal_name)
	
	if Input.is_action_just_pressed(next_character_input_action):
		var next_index = current_index + 1
		if next_index >= internal_characters.keys().size():
			next_index = 0
		
		return handle_switch_to_character(next_index)
	elif Input.is_action_just_pressed(previous_character_input_action):
		var previous_index = current_index - 1
		if previous_index < 0:
			previous_index = internal_characters.keys().size() - 1
		
		return handle_switch_to_character(previous_index)
	
	return false

## Switches [member PlayableCharacterCharacterContainer.current_character] depending on the given
## index.
##
## Takes [param index] for the index of the [Character] to switch to. The [Character] must have
## been added via [method PlayableCharacterCharacterContainer.add_character].
func handle_switch_to_character(index: int) -> bool:
	if not can_switch_characters:
		return false
	
	if (index < 0) or (index >= internal_characters.keys().size()):
		character_switch_failed.emit()
		return false
	
	# if characters[index].get_character_status().is_dead():
	# 	character_switch_failed.emit()
	# 	return false
	
	var old
	if not current_character:
		old = null
	elif current_character.get_parent() == self:
		old = current_character
		remove_child(current_character)
	current_character = characters[index]
	add_child(current_character)
	current_character_changed.emit(old, current_character)
	
	return true
