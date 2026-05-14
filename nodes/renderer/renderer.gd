@tool
extends Renderer
## Applies settings from [PlayerConfig] to a [Renderer] node.

## The source config key that this [Renderer]'s resolution will be set to.
@export var source: StringName = AppSettings.GAME_RESOLUTION

func _ready() -> void:
	PlayerConfig.config_set.connect(_on_player_config_config_set)
	_update_resolution()

func _on_player_config_config_set():
	_update_resolution()

func _update_resolution():
	resolution = PlayerConfig.get_config(AppSettings.VIDEO_SECTION, source, get_window().size)
