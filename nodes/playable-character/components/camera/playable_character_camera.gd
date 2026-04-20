@tool
extends PlayableCharacterCamera
## Applies settings from [PlayerConfig] to a [PlayableCharacterCamera] node.

const MOUSE_SENSITIVITY_STRING = "mouse_sensitivity"
const CONTROLLER_SENSITIVITY_STRING = ""

func _ready() -> void:
	PlayerConfig.config_set.connect(_on_player_config_config_set)
	_update_mouse_sensitivity()
	# _update_controller_sensitivity()

func _on_player_config_config_set():
	_update_mouse_sensitivity()
	# _update_controller_sensitivity()

func _update_mouse_sensitivity():
	var sensitivity = PlayerConfig.get_config(AppSettings.INPUT_SECTION, MOUSE_SENSITIVITY_STRING, 1.0)
	mouse_x_sensitivity = sensitivity
	mouse_y_sensitivity = sensitivity
