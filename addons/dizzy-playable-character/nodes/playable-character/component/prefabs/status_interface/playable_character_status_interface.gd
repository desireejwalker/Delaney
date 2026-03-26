class_name PlayableCharacterStatusInterface
extends PlayableCharacterComponent
## A [PlayableCharacter] component responsible for interacting with the [Status] resource
## on [member PlayableCharacterCharacterContainer.current_character].

var _status: Status

func initialize(playable_character: PlayableCharacter):
	_status = playable_character.character_container.current_character.status
	super(playable_character)
