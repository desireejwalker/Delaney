class_name MainUI extends CanvasLayer

@onready var _minimap_subviewport = $MinimapControl/MaskTextureRect/MapSubViewportContainer/SubViewport
@onready var _player_marker = $MinimapControl/MaskTextureRect/MapSubViewportContainer/SubViewport/PlayerMarker

func set_marker_tilemap(marker_tilemap: TileMap):
	marker_tilemap.reparent(_minimap_subviewport)
	marker_tilemap.visible = true

func set_player_marker_rotation(rotation_radians: float):
	_player_marker.rotation = rotation_radians
func set_player_marker_position(position: Vector2):
	_player_marker.position = position

