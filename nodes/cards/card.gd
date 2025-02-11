class_name Card extends Node
## A Card is an item pick-up that modifies the attributes of entities.

## a description of how the card affects entities in the UPRIGHT position.
@export_multiline var upright_description: String
## a shortened description of how the card affects entities in the UPRIGHT position.
@export_multiline var upright_short_description: String
## a description of how the card affects entities in the REVERSED position.
@export_multiline var reversed_description: String
## a shortened description of how the card affects entities in the REVERSED position.
@export_multiline var reversed_short_description: String

## the affector to be applied to entities in the UPRIGHT position.
@export var upright_affector: Affector
## the affector to be applied to entities in the REVERSED position.
@export var reversed_affector: Affector

var reversed: bool
