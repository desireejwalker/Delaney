class_name CardSelectScreen extends CanvasLayer

const SELECTABLE_CARD = preload("res://nodes/cards/card_select/selectable_card/selectable_card.tscn")

@onready var _cards_parent = $Cards

@export var angle_spread = 120

var _cards_number: int

func _ready():
	set_cards_number(9)
	show_cards()

func set_cards_number(number: int):
	_cards_number = number

func show_cards():
	var angle_degrees = -(angle_spread / 2)
	var angle_increment_degrees = angle_spread / (_cards_number - 1)
	
	for i in range(_cards_number):
		var selectable_card = SELECTABLE_CARD.instantiate()
		selectable_card.rotation_degrees = angle_degrees
		angle_degrees += angle_increment_degrees
		_cards_parent.add_child(selectable_card)
		
		await get_tree().create_timer(0.1).timeout
