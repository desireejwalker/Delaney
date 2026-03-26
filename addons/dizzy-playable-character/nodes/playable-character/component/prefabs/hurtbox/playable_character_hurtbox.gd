class_name PlayableCharacterHurtbox
extends PlayableCharacterComponent
## A [PlayableCharacter] component responsible for detection of [Hitbox]es. Will provide the
## correct hurtbox to a [PlayableCharacter] depending on 
## [member PlayableCharacterCharacterContainer.current_character] and that [Character]'s
## [CharacterHurtbox].

# Components

@onready var _hurtbox: Hurtbox = %Hurtbox

## The [Hurtbox] that is currently being used. When set, will update this
## [PlayableCharacterHurtbox]'s internal [Hurtbox] node with the given [CharacterHurtbox]'s
## [member CharacterHurtbox.shape] and [member CharacterHurtbox.position].
var character_hurtbox: CharacterHurtbox:
	set(value):
		character_hurtbox = value
		_setup_character_hurtbox()

func initialize(playable_character: PlayableCharacter):
	playable_character.character_container.current_character_changed.connect(_on_character_container_current_character_changed)
	character_hurtbox = playable_character.character_container.current_character.hurtbox
	super(playable_character)

func _setup_character_hurtbox():
	if not is_active:
		return
	if not character_hurtbox:
		return
	
	_hurtbox.shape = character_hurtbox.shape
	_hurtbox.position = character_hurtbox.position

func _on_character_container_current_character_changed(old: Character, new: Character):
	if not is_active:
		return
	character_hurtbox = new.hurtbox

func _on_hurtbox_hit(hitbox: Hitbox) -> void:
	if not is_active:
		return
	var damage_instance = hitbox.consume()
	playable_character.status_interface.damage(damage_instance)
