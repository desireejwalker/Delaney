@tool
extends ConfirmationOverlaidWindow

func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("fast_quit"):
		confirm()