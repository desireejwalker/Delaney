class_name SelectableCard extends Control

@onready var animation_player = $AnimationPlayer

func _on_button_pressed():
	animation_player.play("RESET")
	animation_player.speed_scale = 1
	animation_player.play("selected")

func _on_spread_animation_finished():
	animation_player.play("RESET")
	animation_player.speed_scale = randf_range(0.8, 1.2)
	animation_player.play("idle")
