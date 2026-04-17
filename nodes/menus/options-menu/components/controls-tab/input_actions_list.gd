@tool
extends InputActionsList

@export_group("Input Action Name")
@export var input_action_name_prefix: String
@export var input_action_name_suffix: String

@export_group("Buttons")
@export var input_action_button_text_prefix: String
@export var input_action_button_text_suffix: String
@export var input_action_button_font: Font
@export var input_action_button_font_size: int

func _add_new_button(content : Variant, container: Control, disabled : bool = false) -> Button:
	var new_button: Button = Button.new()
	if button_minimum_size.x > 0:
		new_button.custom_minimum_size.x = button_minimum_size.x
		new_button.size_flags_horizontal = SIZE_SHRINK_CENTER
	else:
		new_button.size_flags_horizontal = SIZE_EXPAND_FILL
	if button_minimum_size.y > 0:
		new_button.custom_minimum_size.y = button_minimum_size.y
		new_button.size_flags_vertical = SIZE_SHRINK_CENTER
	else:
		new_button.size_flags_vertical = SIZE_EXPAND_FILL
	new_button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	new_button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	new_button.expand_icon = expand_icon
	if content is Texture:
		new_button.icon = content
	elif content is String:
		new_button.text = input_action_button_text_prefix+content+input_action_button_text_suffix if content != EMPTY_INPUT_ACTION_STRING else content
		new_button.add_theme_font_override(&"font", input_action_button_font)
		new_button.add_theme_font_size_override(&"font_size", input_action_button_font_size)
	new_button.disabled = disabled
	container.add_child(new_button)
	return new_button

func _update_assigned_inputs_and_button(action_name : String, action_group : int, input_event : InputEvent) -> void:
	var new_readable_input_name = InputEventHelper.get_text(input_event)
	var button = _get_button_by_action(action_name, action_group)
	if not button: return
	var icon : Texture
	if input_icon_mapper:
		icon = input_icon_mapper.get_icon(input_event)
	if icon:
		button.icon = icon
	else:
		button.icon = null
	if button.icon == null:
		var text = _handle_mouse_button_renaming(new_readable_input_name)
		button.text = input_action_button_text_prefix+text+input_action_button_text_suffix
	else:
		button.text = ""
	var old_readable_input_name : String
	if button in button_readable_input_map:
		old_readable_input_name = button_readable_input_map[button]
		assigned_input_events.erase(old_readable_input_name)
	button_readable_input_map[button] = new_readable_input_name
	assigned_input_events[new_readable_input_name] = action_name

func _handle_mouse_button_renaming(text: String) -> String:
	if text == "Left Mouse Button":
		return "LMB"
	if text == "Right Mouse Button":
		return "RMB"
	if text == "Middle Mouse Button":
		return "MMB"
	return text

func _add_action_options(action_name : String, readable_action_name : String, input_events : Array[InputEvent]) -> void:
	var new_action_box = %ActionBoxContainer.duplicate()
	new_action_box.visible = true
	new_action_box.vertical = !(vertical)
	new_action_box.get_child(0).text = input_action_name_prefix+readable_action_name.to_upper()+input_action_name_suffix
	for group_iter in range(action_groups):
		var input_event: InputEvent
		if group_iter < input_events.size():
			input_event = input_events[group_iter]
		var text = InputEventHelper.get_text(input_event)
		text = _handle_mouse_button_renaming(text)
		var is_disabled = group_iter > input_events.size()
		if text.is_empty():
			text = EMPTY_INPUT_ACTION_STRING
		var icon: Texture
		if input_icon_mapper:
			icon = input_icon_mapper.get_icon(input_event)
		var content = icon if icon else text
		var button: Button = _add_new_button(content, new_action_box, is_disabled)
		_connect_button_and_add_to_maps(button, text, action_name, group_iter)
	%ParentBoxContainer.add_child(new_action_box)
