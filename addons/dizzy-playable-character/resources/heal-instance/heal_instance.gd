class_name HealInstance
extends Resource

## responsible for communicating any information about any source of healing to any Status resource.

## The originator of the heal.
var source: Node

## The amount of health to apply.
@export var heal: int

## Spawn a status number when consumed?
@export var spawn_status_number: bool