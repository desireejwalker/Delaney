class_name HealthBarComponent extends Sprite2D
## Responsible for visual representation of a [HealthComponent]'s attributes.

## the [HealthComponent] that will be represented.
@export var _health_component: HealthComponent

@onready var _health_bar = $bar/HealthBar

func _ready():
	_health_bar.max_value = _health_component.max_health
	
	_health_component.on_current_health_incremented.connect(_on_health_component_current_health_incremented)
	_health_component.on_current_health_decremented.connect(_on_health_component_current_health_decremented)
	_health_component.on_current_health_depleted.connect(_on_health_component_current_health_depleted)

func _on_health_component_current_health_incremented():
	_health_bar.value = _health_component.current_health
func _on_health_component_current_health_decremented():
	_health_bar.value = _health_component.current_health
func _on_health_component_current_health_depleted():
	_health_bar.value = _health_component.current_health
