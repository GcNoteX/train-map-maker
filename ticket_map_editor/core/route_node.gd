@tool
extends Line2D
class_name RouteNode

@export_category("Route Data")
@export var from_city: CityNode:
	set(value):
		from_city = value
		_ensure_neutral_transform()
		_ensure_point_count_preserving_shape()
		_snap_endpoints_to_cities()
		_refresh_visuals()

@export var to_city: CityNode:
	set(value):
		to_city = value
		_ensure_neutral_transform()
		_ensure_point_count_preserving_shape()
		_snap_endpoints_to_cities()
		_refresh_visuals()

@export_range(1, 12, 1) var route_length: int = 3:
	set(value):
		var new_value: int = max(1, value)
		if route_length == new_value:
			return

		route_length = new_value
		_apply_route_length_change()

@export var cart_type: CartTypes.CartType = CartTypes.CartType.NONE:
	set(value):
		cart_type = value
		_refresh_visuals()

@export_category("Label")
@export var use_node_name_for_label: bool = true:
	set(value):
		use_node_name_for_label = value
		_refresh_visuals()

@export var label_offset: Vector2 = Vector2(0, -22):
	set(value):
		label_offset = value
		_refresh_visuals()

@export var use_route_color_for_label: bool = true:
	set(value):
		use_route_color_for_label = value
		_refresh_visuals()

@export var manual_label_color: Color = Color(1, 1, 1, 1):
	set(value):
		manual_label_color = value
		_refresh_visuals()

@export_range(0, 8, 1) var label_outline_size: int = 3:
	set(value):
		label_outline_size = max(value, 0)
		_refresh_visuals()

@export_category("Line Visuals")
@export var line_width: float = 12.0:
	set(value):
		line_width = max(value, 1.0)
		_refresh_visuals()

@export var keep_endpoints_snapped: bool = true:
	set(value):
		keep_endpoints_snapped = value
		if keep_endpoints_snapped:
			_snap_endpoints_to_cities()
		_refresh_visuals()

@export_category("Segment Visuals")
@export var segment_size: Vector2 = Vector2(18, 10):
	set(value):
		segment_size = Vector2(max(value.x, 1.0), max(value.y, 1.0))
		queue_redraw()
		_refresh_visuals()

@export var segment_outline_width: float = 2.0:
	set(value):
		segment_outline_width = max(value, 0.0)
		queue_redraw()

@export var segment_outline_color: Color = Color(1, 1, 1, 1):
	set(value):
		segment_outline_color = value
		queue_redraw()

@export var show_segment_arrows: bool = true:
	set(value):
		show_segment_arrows = value
		queue_redraw()

@export var segment_arrow_color: Color = Color(0, 0, 0, 1):
	set(value):
		segment_arrow_color = value
		queue_redraw()

@export_range(1.0, 8.0, 0.5) var segment_arrow_width: float = 2.0:
	set(value):
		segment_arrow_width = max(value, 1.0)
		queue_redraw()

@export_range(0.1, 1.0, 0.05) var segment_arrow_length_ratio: float = 0.45:
	set(value):
		segment_arrow_length_ratio = clamp(value, 0.1, 1.0)
		queue_redraw()

@export_range(0.1, 1.0, 0.05) var segment_arrow_head_ratio: float = 0.3:
	set(value):
		segment_arrow_head_ratio = clamp(value, 0.1, 1.0)
		queue_redraw()

@onready var route_label: Label = $RouteLabel

func _ready() -> void:
	_ensure_neutral_transform()
	_apply_route_length_change()

func _process(_delta: float) -> void:
	if not Engine.is_editor_hint():
		return

	if not is_node_ready():
		return

	_ensure_neutral_transform()

	var expected_point_count: int = route_length + 2
	if points.size() != expected_point_count:
		_ensure_point_count_preserving_shape()

	if keep_endpoints_snapped:
		_snap_endpoints_to_cities()

	_refresh_visuals()
	queue_redraw()

func _draw() -> void:
	if not is_node_ready():
		return

	if points.size() < 3:
		return

	for i in range(1, points.size() - 1):
		var current_point: Vector2 = points[i]
		var previous_point: Vector2 = points[i - 1]
		var next_point: Vector2 = points[i + 1]

		var direction: Vector2 = next_point - previous_point
		var rotation_radians: float = direction.angle()

		draw_set_transform(current_point, rotation_radians, Vector2.ONE)

		var rect := Rect2(-segment_size * 0.5, segment_size)
		draw_rect(rect, CartTypes.to_color(cart_type), true)

		if segment_outline_width > 0.0:
			draw_rect(rect, segment_outline_color, false, segment_outline_width)

		if show_segment_arrows:
			_draw_segment_arrow()

	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

## Keeps this route untransformed so editing is done through points, not node movement.
func _ensure_neutral_transform() -> void:
	if position != Vector2.ZERO:
		position = Vector2.ZERO

	if rotation != 0.0:
		rotation = 0.0

	if scale != Vector2.ONE:
		scale = Vector2.ONE

## Applies all editor updates required after route_length changes.
func _apply_route_length_change() -> void:
	if not is_node_ready():
		return

	_ensure_neutral_transform()
	_ensure_point_count_preserving_shape()
	_snap_endpoints_to_cities()
	_refresh_visuals()
	queue_redraw()

	if Engine.is_editor_hint():
		notify_property_list_changed()

## Preserves existing interior shape where possible.
## New interior points default to the midpoint between the city endpoints.
func _ensure_point_count_preserving_shape() -> void:
	if not is_node_ready():
		return

	var expected_count: int = route_length + 2

	var start_point: Vector2 = Vector2.ZERO
	var end_point: Vector2 = Vector2(36.0 * float(expected_count - 1), 0.0)

	if points.size() >= 2:
		start_point = points[0]
		end_point = points[points.size() - 1]

	if from_city != null:
		start_point = to_local(from_city.global_position)

	if to_city != null:
		end_point = to_local(to_city.global_position)

	var midpoint: Vector2 = start_point.lerp(end_point, 0.5)

	var old_interior_points: Array[Vector2] = []
	if points.size() >= 3:
		for i in range(1, points.size() - 1):
			old_interior_points.append(points[i])

	var new_points: PackedVector2Array = PackedVector2Array()
	new_points.append(start_point)

	for i in range(route_length):
		if i < old_interior_points.size():
			new_points.append(old_interior_points[i])
		else:
			new_points.append(midpoint)

	new_points.append(end_point)

	points = new_points

## Snaps only the first and last points to the assigned cities.
func _snap_endpoints_to_cities() -> void:
	if not is_node_ready():
		return

	if points.size() < 2:
		return

	var new_points: PackedVector2Array = points

	if from_city != null:
		new_points[0] = to_local(from_city.global_position)

	if to_city != null:
		new_points[new_points.size() - 1] = to_local(to_city.global_position)

	points = new_points

## Draws a small right-facing arrow centered inside the local segment rectangle.
func _draw_segment_arrow() -> void:
	var arrow_length: float = segment_size.x * segment_arrow_length_ratio
	var arrow_head_size: float = min(segment_size.x, segment_size.y) * segment_arrow_head_ratio

	var start: Vector2 = Vector2(-arrow_length * 0.5, 0.0)
	var end: Vector2 = Vector2(arrow_length * 0.5, 0.0)

	draw_line(start, end, segment_arrow_color, segment_arrow_width)

	var head_back: float = arrow_head_size
	var head_half_height: float = arrow_head_size * 0.5

	draw_line(
		end,
		end + Vector2(-head_back, -head_half_height),
		segment_arrow_color,
		segment_arrow_width
	)

	draw_line(
		end,
		end + Vector2(-head_back, head_half_height),
		segment_arrow_color,
		segment_arrow_width
	)

## Updates route text and color-related visuals.
func _refresh_visuals() -> void:
	if not is_node_ready():
		return

	var route_color: Color = CartTypes.to_color(cart_type)

	width = line_width
	default_color = route_color

	var from_text: String = ""
	var to_text: String = ""

	if from_city != null:
		from_text = from_city.city_id
	if to_city != null:
		to_text = to_city.city_id

	if use_node_name_for_label:
		route_label.text = name
	else:
		route_label.text = "%s_to_%s (%d)" % [from_text, to_text, route_length]
	route_label.position = _get_midpoint() + label_offset
	route_label.visible = true

	var label_fill_color: Color = route_color if use_route_color_for_label else manual_label_color
	route_label.add_theme_color_override("font_color", label_fill_color)
	route_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	route_label.add_theme_constant_override("outline_size", label_outline_size)

## Finds a midpoint along the whole route polyline for label placement.
func _get_midpoint() -> Vector2:
	if points.is_empty():
		return Vector2.ZERO

	if points.size() == 1:
		return points[0]

	var total_length: float = 0.0
	for i in range(points.size() - 1):
		total_length += points[i].distance_to(points[i + 1])

	var halfway_distance: float = total_length * 0.5
	var walked_distance: float = 0.0

	for i in range(points.size() - 1):
		var a: Vector2 = points[i]
		var b: Vector2 = points[i + 1]
		var segment_length: float = a.distance_to(b)

		if segment_length <= 0.0:
			continue

		if walked_distance + segment_length >= halfway_distance:
			var t: float = (halfway_distance - walked_distance) / segment_length
			return a.lerp(b, t)

		walked_distance += segment_length

	return points[points.size() - 1]
