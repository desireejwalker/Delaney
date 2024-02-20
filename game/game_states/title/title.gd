class_name Title extends CanvasLayer

signal start_button_pressed
signal quit_button_pressed

@onready var start_button = $ButtonContainer/StartButton
@onready var quit_button = $ButtonContainer/QuitButton

func _ready():
	start_button.pressed.connect(_start_button_pressed)
	quit_button.pressed.connect(_quit_button_pressed)

func _start_button_pressed():
	start_button_pressed.emit()

func _quit_button_pressed():
	quit_button_pressed.emit()

func _exit_tree():
	start_button.pressed.disconnect(_start_button_pressed)
	quit_button.pressed.disconnect(_quit_button_pressed)
