@tool
extends FSMState

# Components

var playable_character: PlayableCharacter
var pauseable_entities: Array

@onready var world_renderer: Renderer = %WorldRenderer

func _ready():
	pass
	# playable_character = await _get_playable_character()
	# pauseable_entities = []

# Executes after the state is entered.
func _on_enter(_actor: Node, _blackboard: Blackboard) -> void:
	print("gameplay")
	print(transitions)
	# if playable_character:
	# 	playable_character.set_process(true)

# Executes every _process call, if the state is active.
func _on_update(_delta: float, _actor: Node, _blackboard: Blackboard) -> void:
	pass

# Executes before the state is exited.
func _on_exit(_actor: Node, _blackboard: Blackboard) -> void:
	pass

func _get_playable_character() -> PlayableCharacter:
	if not world_renderer.is_active:
		await world_renderer.initialized
	return world_renderer.get_node("%DelaneyPlayableCharacter") as PlayableCharacter
