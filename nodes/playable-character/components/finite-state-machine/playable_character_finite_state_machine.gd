@tool
class_name PlayableCharacterFiniteStateMachine
extends PlayableCharacterComponent

## If true, state changes made will be printed to the console.
@export var verbose: bool

# Components

## The [FiniteStateMachine] that this [PlayableCharacterFiniteStateMachine] will use to control the
## [PlayableCharacter].
var finite_state_machine: FiniteStateMachine

func initialize(playable_character: PlayableCharacter):
	finite_state_machine = get_child(0)
	finite_state_machine.state_changed.connect(_on_finite_state_machine_state_changed)
	finite_state_machine.start()

	super(playable_character)

func _on_finite_state_machine_state_changed(state: FSMState):
	if not verbose:
		return
	
	print("State changed to: " + state.name)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings = []
	var children = get_children()
	if children.size() > 1:
		warnings.append(
            "There should only be one child of a PlayableCharacterFiniteStateMachine node."
		)
	if children.is_empty() or not children[0] is FiniteStateMachine:
		warnings.append(
            "The child of a PlayableCharacterFiniteStateMachine node should be a
            FiniteStateMachine."
		) 
	
	return warnings
