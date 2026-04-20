@tool
extends OverlaidWindow

@export var how_to_play_menu_scene: PackedScene
@export var options_menu_scene: PackedScene
## Path to a main menu scene.
## Will attempt to read from AppConfig if left empty.
@export_file("*.tscn") var main_menu_scene_path: String

var open_window: Node
var _ignore_first_cancel: bool = false

@onready var menu_container: Node = $".."
@onready var restart_confirmation: ConfirmationOverlaidWindow = %RestartConfirmationOverlaidWindow
@onready var quit_confirmation: ConfirmationOverlaidWindow = %QuitConfirmationOverlaidWindow

func _ready() -> void:
	restart_confirmation.confirmed.connect(_on_restart_confirmation_confirmed)
	quit_confirmation.confirmed.connect(_on_quit_confirmation_confirmed)

func _unhandled_input(_event : InputEvent) -> void:
	pass

func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("pause"):
		_handle_cancel_input()
		get_viewport().set_input_as_handled()
	if event.is_action_pressed("fast_quit"):
		_quit()

func _quit():
	_show_window(quit_confirmation)

func _load_scene(scene_path: String) -> void:
	_scene_tree.paused = false
	SceneLoader.load_scene(scene_path)

func close_window() -> void:
	if open_window != null:
		if open_window.has_method("close"):
			open_window.close()
		else:
			open_window.hide()
		open_window = null

func _show_window(window : Control) -> void:
	_disable_focus.call_deferred()
	window.show()
	open_window = window
	await window.hidden
	open_window = null
	_enable_focus.call_deferred()

func _load_and_show_menu(scene : PackedScene) -> void:
	var window_instance : Control = scene.instantiate()
	window_instance.visible = false
	menu_container.add_child.call_deferred(window_instance)
	await _show_window(window_instance)
	window_instance.queue_free()

func _disable_focus() -> void:
	for child in %MenuButtons.get_children():
		if child is Control:
			child.focus_mode = FOCUS_NONE

func _enable_focus() -> void:
	for child in %MenuButtons.get_children():
		if child is Control:
			child.focus_mode = FOCUS_ALL

func _handle_cancel_input() -> void:
	if _ignore_first_cancel:
		_ignore_first_cancel = false
		return
	if open_window != null:
		close_window()
	else:
		super._handle_cancel_input()

func show() -> void:
	super.show()
	if Input.is_action_pressed("pause"):
		_ignore_first_cancel = true

func _on_restart_button_pressed() -> void:
	_show_window(restart_confirmation)

func _on_how_to_play_button_pressed() -> void:
	_load_and_show_menu(how_to_play_menu_scene)

func _on_options_button_pressed() -> void:
	_load_and_show_menu(options_menu_scene)

func _on_quit_button_pressed() -> void:
	_quit()

func _on_restart_confirmation_confirmed() -> void:
	SceneLoader.reload_current_scene()
	close()

func _on_quit_confirmation_confirmed():
	_load_scene(main_menu_scene_path)
