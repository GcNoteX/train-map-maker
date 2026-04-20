@tool
extends Node2D
class_name CityNode

@export_category("City Data")
@export var city_id: String = "city_id":
	set(value):
		city_id = value
		_refresh_visuals()

@export var display_name: String = "City":
	set(value):
		display_name = value
		_refresh_visuals()

@export_category("Label")
@export var use_node_name_for_label: bool = false:
	set(value):
		use_node_name_for_label = value
		_refresh_visuals()

@export var label_offset: Vector2 = Vector2(14, -28):
	set(value):
		label_offset = value
		_refresh_visuals()

@export var use_marker_color_for_label: bool = true:
	set(value):
		use_marker_color_for_label = value
		_refresh_visuals()

@export var manual_label_color: Color = Color(1, 1, 1, 1):
	set(value):
		manual_label_color = value
		_refresh_visuals()

@export_range(0, 8, 1) var label_outline_size: int = 3:
	set(value):
		label_outline_size = max(value, 0)
		_refresh_visuals()

@export_category("Marker Visuals")
@export var marker_radius: float = 8.0:
	set(value):
		marker_radius = max(value, 1.0)
		queue_redraw()
		_refresh_visuals()

@export var marker_color: Color = Color(0.9, 0.2, 0.2, 1.0):
	set(value):
		marker_color = value
		queue_redraw()
		_refresh_visuals()

@export var outline_color: Color = Color(1, 1, 1, 1):
	set(value):
		outline_color = value
		queue_redraw()

@export var outline_width: float = 2.0:
	set(value):
		outline_width = max(value, 0.0)
		queue_redraw()

@onready var name_label: Label = $NameLabel

func _ready() -> void:
	_refresh_visuals()
	queue_redraw()

func _draw() -> void:
	draw_circle(Vector2.ZERO, marker_radius, marker_color)
	if outline_width > 0.0:
		draw_arc(
			Vector2.ZERO,
			marker_radius,
			0.0,
			TAU,
			24,
			outline_color,
			outline_width
		)

## Keeps the editor label synced with exported city data.
func _refresh_visuals() -> void:
	if not is_node_ready():
		return
	if use_node_name_for_label:
		name_label.text = name  
	else: 
		name_label.text = display_name
	name_label.position = label_offset
	name_label.visible = true

	var label_fill_color: Color = marker_color if use_marker_color_for_label else manual_label_color
	name_label.add_theme_color_override("font_color", label_fill_color)
	name_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	name_label.add_theme_constant_override("outline_size", label_outline_size)

	if Engine.is_editor_hint():
		queue_redraw()
