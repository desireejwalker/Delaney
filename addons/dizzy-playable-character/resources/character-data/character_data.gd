class_name CharacterData
extends Resource
## Holds data pertaining to the information (name, description, etc) of a [Character].

# Name

## The character's name.
@export var name: String
## The character's internal name. This is used as an identifier for a character.
@export var internal_name: StringName

# Description

@export_multiline var short_description: String
@export_multiline var long_description: String