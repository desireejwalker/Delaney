class_name Character
extends Node3D
## A node responsible for a character, their attacks, their [CharacterModel], [AnimationTree], etc.
## Should be the child of a [PlayableCharacterCharacterContainer] node when used with a
## [PlayableCharacter].

## The [CharacterData] resource for this [Character].
@export var data: CharacterData
## The [CharacterModel] node for this [Character].
@export var model: CharacterModel

## If true, this [Character] node has ben initialized.
var initialized: bool = false

## The [Status] resource for this [Character].
var status: Status

# Components

## The [AnimationTree] node that this [Character]'s animations are used in.
@onready var animation_tree: AnimationTree = %AnimationTree
## The [CharacterHurtbox] node for this [Character].
@onready var hurtbox: CharacterHurtbox = %CharacterHurtbox

func initialize():
    initialized = true