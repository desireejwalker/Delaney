class_name StaminaWheel
extends Control

## The maximum value of the stamina wheel.
var max_value: float:
	set(value):
		max_value = value
		%TextureProgressBar.max_value = max_value
## The current value of the stamina wheel.
var current_value: float:
	set(value):
		current_value = value
		%TextureProgressBar.value = current_value

func show_wheel():
	%AnimationPlayer.play("show")
func hide_wheel():
	%AnimationPlayer.play("hide")