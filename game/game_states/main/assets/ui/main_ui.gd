class_name MainUI extends CanvasLayer

const COMBO_LABEL = preload("res://game/game_states/main/assets/ui/combo/combo_label.tscn")

@onready var _points_animation_player = $PointsControl/PointsAnimationPlayer
@onready var _points_counter: Label = $PointsControl/PointsCounterControl/Label

@onready var _combo_action_list_parent := $PointsControl/ComboActionListControl/MaskTextureRect/VBoxContainer

@onready var _delta_progress_bar: TextureProgressBar = $PointsControl/DeltaComboLevelTitleControl/TextureProgressBar
@onready var _delta_animation_player: AnimationPlayer = $PointsControl/DeltaComboLevelTitleControl/AnimationPlayer
@onready var _epsilon_progress_bar: TextureProgressBar = $PointsControl/EpsilonComboLevelTitleControl/TextureProgressBar
@onready var _epsilon_animation_player: AnimationPlayer = $PointsControl/EpsilonComboLevelTitleControl/AnimationPlayer
@onready var _lambda_progress_bar: TextureProgressBar = $PointsControl/LambdaComboLevelTitleControl/TextureProgressBar
@onready var _lambda_animation_player: AnimationPlayer = $PointsControl/LambdaComboLevelTitleControl/AnimationPlayer

@onready var _minimap_subviewport = $MinimapControl/MaskTextureRect/MapSubViewportContainer/SubViewport
@onready var _player_marker = $MinimapControl/MaskTextureRect/MapSubViewportContainer/SubViewport/PlayerMarker

# combo
enum ComboLevel
{
	NONE,
	DELTA,
	EPSILON,
	LAMBDA
}
var _combo_level: ComboLevel = ComboLevel.NONE:
	set(value):
		_combo_level = value
		_update_combo_level()
var _combo_time_left: float = 999.0:
	set(value):
		_combo_time_left = value
		_update_combo_progress_bar()

# points
var _target_points: int = 0
var _points: int = 0:
	set(value):
		_points = value
		_update_points_counter()

# combo list
var _combo_action_list: Array[Array] = []
var _queue_clear_combo_actions: bool = false

func _ready():
	pass

func _process(delta):
	_handle_points(delta)

func show_points_overlay():
	_points_animation_player.play("show")
func hide_points_overlay():
	_points_animation_player.play("hide")
func _on_points_overlay_offscreen():
	if _queue_clear_combo_actions:
		_clear_combo_actions()

func _update_combo_level():
	match _combo_level:
		ComboLevel.DELTA:
			_epsilon_animation_player.get_parent().visible = false
			_lambda_animation_player.get_parent().visible = false
			_delta_animation_player.play("show")
		ComboLevel.EPSILON:
			_delta_animation_player.get_parent().visible = false
			_lambda_animation_player.get_parent().visible = false
			_epsilon_animation_player.play("show")
		ComboLevel.LAMBDA:
			_delta_animation_player.get_parent().visible = false
			_epsilon_animation_player.get_parent().visible = false
			_lambda_animation_player.play("show")
func set_combo_level(combo_level: ComboLevel):
	_combo_level = combo_level

func _update_combo_progress_bar():
	match _combo_level:
		ComboLevel.DELTA:
			_delta_progress_bar.value = remap(_combo_time_left, 0, 5, 0, 1)
		ComboLevel.EPSILON:
			_epsilon_progress_bar.value = remap(_combo_time_left, 0, 3.5, 0, 1)
		ComboLevel.LAMBDA:
			_lambda_progress_bar.value = remap(_combo_time_left, 0, 2, 0, 1)
func set_combo_time_left(combo_time_left):
	_combo_time_left = combo_time_left

func _update_points_counter():
	var string = str(_points)
	var mod = string.length() % 3
	var res = ""
	for i in range(0, string.length()):
		if i != 0 && i % 3 == mod:
			res += ","
		res += string[i]
	_points_counter.text = str(res) + "pts"
func set_target_points(points):
	_target_points = points
func _handle_points(delta):
	if _points == _target_points:
		return
	
	if _target_points - _points >= 1_000_000_000_000:
		_points += 1_000_000_000_000
	elif _target_points - _points >= 1_000_000_000:
		_points += 1_000_000_000
	elif _target_points - _points >= 1_000_000:
		_points += 1_000_000
	elif _target_points - _points >= 1_000:
		_points += 1_000
	elif _target_points - _points >= 100:
		_points += 100
	elif _target_points - _points >= 10:
		_points += 10
	elif _target_points - _points >= 1:
		_points += 1

func add_combo_action(combo_action: ComboActionEntry):
	var combo_label_instance = COMBO_LABEL.instantiate()
	combo_label_instance.text = combo_action._to_string()
	_combo_action_list.append([combo_action, combo_label_instance])
	_combo_action_list_parent.add_child(combo_label_instance)
	
	# if there are more than 5 combo actions onscreen, remove the last
	if _combo_action_list.size() > 5:
		_combo_action_list[0][1].queue_free()
		_combo_action_list.remove_at(0)
func queue_clear_combo_actions():
	_queue_clear_combo_actions = true
func _clear_combo_actions():
	for combo_action in _combo_action_list:
		combo_action[1].queue_free()
	_combo_action_list = []

func set_marker_tilemap(marker_tilemap: TileMap):
	var new_marker_tilemap = marker_tilemap.duplicate()
	_minimap_subviewport.add_child(new_marker_tilemap)
	marker_tilemap.visible = true

func set_player_marker_rotation(rotation_radians: float):
	_player_marker.rotation = rotation_radians
func set_player_marker_position(position: Vector2):
	_player_marker.position = position
