@tool
extends Node2D
class_name TicketMapEditor

@export_category("Map Data")
@export var map_id: String = "ticket_map":
	set(value):
		map_id = value
		_refresh_default_export_paths_from_map_id()

@export var map_size: Vector2 = Vector2(1200, 800):
	set(value):
		map_size = Vector2(max(value.x, 1.0), max(value.y, 1.0))
		_refresh_background()
		queue_redraw()

@export_category("Map Bounds Visual")
@export var show_map_bounds: bool = true:
	set(value):
		show_map_bounds = value
		queue_redraw()

@export var bounds_color: Color = Color(0.2, 0.9, 1.0, 0.9):
	set(value):
		bounds_color = value
		queue_redraw()

@export var bounds_width: float = 3.0:
	set(value):
		bounds_width = max(value, 1.0)
		queue_redraw()

@export_category("Blueprint Background")
@export var background_texture: Texture2D:
	set(value):
		background_texture = value
		_refresh_background()

@export var background_modulate: Color = Color(1, 1, 1, 0.45):
	set(value):
		background_modulate = value
		_refresh_background()

@export var fit_background_to_map_size: bool = true:
	set(value):
		fit_background_to_map_size = value
		_refresh_background()

@export_category("Export")
@export var normalize_to_positive_coordinates: bool = true

@export_file("*.json") var export_json_path: String = "res://workspace/exports/example_map.json":
	set(value):
		export_json_path = value

@export_file("*.tres") var export_map_data_resource_path: String = "res://workspace/map_data/example_map_data.tres":
	set(value):
		export_map_data_resource_path = value

@onready var background_sprite: Sprite2D = $BackgroundSprite
@onready var cities_root: Node2D = $Cities
@onready var routes_root: Node2D = $Routes

@export_tool_button("Export Map JSON")
var export_map_json_action := _export_map_json
@export_tool_button("Export Map Data Resource")
var export_map_data_resource_action := _export_map_data_resource

func _ready() -> void:
	_refresh_default_export_paths_from_map_id()
	_refresh_background()
	queue_redraw()

## Updates default export paths from map_id without overwriting clearly custom paths.
func _refresh_default_export_paths_from_map_id() -> void:
	if not is_node_ready():
		return

	var safe_map_id: String = _sanitize_file_name(map_id)
	if safe_map_id.is_empty():
		safe_map_id = "ticket_map"

	var default_json_path: String = "res://workspace/exports/%s.json" % safe_map_id
	var default_tres_path: String = "res://workspace/map_data/%s_map_data.tres" % safe_map_id

	if _should_auto_update_json_path():
		export_json_path = default_json_path

	if _should_auto_update_map_data_path():
		export_map_data_resource_path = default_tres_path

func _should_auto_update_json_path() -> bool:
	return (
		export_json_path.is_empty()
		or export_json_path == "res://workspace/exports/example_map.json"
		or export_json_path == "res://workspace/exports/ticket_map.json"
	)

func _should_auto_update_map_data_path() -> bool:
	return (
		export_map_data_resource_path.is_empty()
		or export_map_data_resource_path == "res://workspace/map_data/map_data.tres"
		or export_map_data_resource_path == "res://workspace/map_data/example_map_data.tres"
		or export_map_data_resource_path == "res://workspace/map_data/ticket_map_map_data.tres"
	)

func _sanitize_file_name(value: String) -> String:
	var result: String = value.strip_edges().to_lower()

	result = result.replace(" ", "_")
	result = result.replace("-", "_")
	result = result.replace("/", "_")
	result = result.replace("\\", "_")
	result = result.replace(":", "_")
	result = result.replace("*", "_")
	result = result.replace("?", "_")
	result = result.replace("\"", "_")
	result = result.replace("<", "_")
	result = result.replace(">", "_")
	result = result.replace("|", "_")
	result = result.replace(".", "_")
	result = result.replace(",", "_")
	result = result.replace("(", "_")
	result = result.replace(")", "_")
	result = result.replace("&", "and")

	while "__" in result:
		result = result.replace("__", "_")

	result = result.trim_prefix("_")
	result = result.trim_suffix("_")

	return result

func _draw() -> void:
	if not show_map_bounds:
		return

	var rect := Rect2(Vector2.ZERO, map_size)
	draw_rect(rect, Color(bounds_color, 0.08), true)
	draw_rect(rect, bounds_color, false, bounds_width)

## Keeps the editor-only blueprint background in sync with the logical map rectangle.
func _refresh_background() -> void:
	if not is_node_ready():
		return

	background_sprite.texture = background_texture
	background_sprite.modulate = background_modulate

	if background_texture == null:
		return

	background_sprite.position = map_size * 0.5

	if fit_background_to_map_size:
		var texture_size: Vector2 = background_texture.get_size()
		if texture_size.x > 0.0 and texture_size.y > 0.0:
			background_sprite.scale = Vector2(
				map_size.x / texture_size.x,
				map_size.y / texture_size.y
			)
	else:
		background_sprite.scale = Vector2.ONE

## Validates then exports the map to JSON.
func _export_map_json() -> void:
	if not _validate_map():
		push_error("Map export failed validation.")
		return

	if not _ensure_export_directory_exists():
		return

	var normalization_offset: Vector2 = Vector2.ZERO
	if normalize_to_positive_coordinates:
		normalization_offset = _compute_normalization_offset()

	var export_data: Dictionary = {
		"map_id": map_id,
		"map_size": _vec2_to_dict(map_size),
		"normalized": normalize_to_positive_coordinates,
		"normalization_offset": _vec2_to_dict(normalization_offset),
		"cities": _collect_cities(normalization_offset),
		"routes": _collect_routes(normalization_offset)
	}

	var json_text: String = JSON.stringify(export_data, "\t")
	var file: FileAccess = FileAccess.open(export_json_path, FileAccess.WRITE)

	if file == null:
		push_error("Failed to open export path: %s" % export_json_path)
		return

	file.store_string(json_text)
	file.close()

	print("Map exported successfully to: %s" % export_json_path)

## Builds and saves a TicketMapData resource from the current editor state.
func _export_map_data_resource() -> void:
	if not _validate_map():
		push_error("Map data resource export failed validation.")
		return

	var map_data: TicketMapData = _build_map_data_resource()

	var save_result: Error = ResourceSaver.save(map_data, export_map_data_resource_path)
	if save_result != OK:
		push_error("Failed to save map data resource: %s" % export_map_data_resource_path)
		return

	print("Map data resource exported successfully to: %s" % export_map_data_resource_path)
## Ensures city IDs are valid and route references are valid before export.
func _validate_map() -> bool:
	if not is_node_ready():
		return false

	var known_city_ids: Dictionary = {}

	for child in cities_root.get_children():
		if not child is CityNode:
			continue

		var city: CityNode = child

		if city.city_id.strip_edges().is_empty():
			push_error("City '%s' has an empty city_id." % city.name)
			return false

		if known_city_ids.has(city.city_id):
			push_error("Duplicate city_id found: %s" % city.city_id)
			return false

		known_city_ids[city.city_id] = city

	for child in routes_root.get_children():
		if not child is RouteNode:
			continue

		var route: RouteNode = child

		if route.from_city == null:
			push_error("Route '%s' is missing from_city." % route.name)
			return false

		if route.to_city == null:
			push_error("Route '%s' is missing to_city." % route.name)
			return false

		if route.from_city == route.to_city:
			push_error("Route '%s' connects a city to itself." % route.name)
			return false

		if not known_city_ids.has(route.from_city.city_id):
			push_error("Route '%s' references from_city outside Cities root or with invalid city_id." % route.name)
			return false

		if not known_city_ids.has(route.to_city.city_id):
			push_error("Route '%s' references to_city outside Cities root or with invalid city_id." % route.name)
			return false

		if route.points.size() != route.route_length + 2:
			push_error("Route '%s' point count does not match route_length + 2." % route.name)
			return false

	return true

## Computes how much to shift exported content so all global geometry is non-negative.
func _compute_normalization_offset() -> Vector2:
	var min_x: float = 0.0
	var min_y: float = 0.0
	var has_any_geometry: bool = false

	for child in cities_root.get_children():
		if not child is CityNode:
			continue

		var city: CityNode = child
		var global_pos: Vector2 = city.global_position

		if not has_any_geometry:
			min_x = global_pos.x
			min_y = global_pos.y
			has_any_geometry = true
		else:
			min_x = min(min_x, global_pos.x)
			min_y = min(min_y, global_pos.y)

	for child in routes_root.get_children():
		if not child is RouteNode:
			continue

		var route: RouteNode = child
		for local_point in route.points:
			var global_point: Vector2 = route.to_global(local_point)

			if not has_any_geometry:
				min_x = global_point.x
				min_y = global_point.y
				has_any_geometry = true
			else:
				min_x = min(min_x, global_point.x)
				min_y = min(min_y, global_point.y)

	if not has_any_geometry:
		return Vector2.ZERO

	return Vector2(
		-min(min_x, 0.0),
		-min(min_y, 0.0)
	)

## Builds exported city dictionaries.
func _collect_cities(normalization_offset: Vector2) -> Array:
	var cities: Array = []

	for child in cities_root.get_children():
		if not child is CityNode:
			continue

		var city: CityNode = child
		var exported_position: Vector2 = city.global_position + normalization_offset

		cities.append({
			"id": city.city_id,
			"display_name": city.display_name,
			"position": _vec2_to_dict(exported_position)
		})

	return cities

## Builds exported route dictionaries, resolving city references into IDs.
func _collect_routes(normalization_offset: Vector2) -> Array:
	var routes: Array = []

	for child in routes_root.get_children():
		if not child is RouteNode:
			continue

		var route: RouteNode = child
		var local_points: PackedVector2Array = route.points

		var all_points_data: Array = []
		for local_point in local_points:
			var global_point: Vector2 = route.to_global(local_point) + normalization_offset
			all_points_data.append(_vec2_to_dict(global_point))

		var segment_points_data: Array = []
		for i in range(1, local_points.size() - 1):
			var prev_global: Vector2 = route.to_global(local_points[i - 1]) + normalization_offset
			var current_global: Vector2 = route.to_global(local_points[i]) + normalization_offset
			var next_global: Vector2 = route.to_global(local_points[i + 1]) + normalization_offset

			var direction: Vector2 = next_global - prev_global
			var rotation_radians: float = direction.angle()

			segment_points_data.append({
				"index": i - 1,
				"position": _vec2_to_dict(current_global),
				"rotation_radians": rotation_radians
			})

		routes.append({
			"node_name": route.name,
			"from_city_id": route.from_city.city_id,
			"to_city_id": route.to_city.city_id,
			"route_length": route.route_length,
			"cart_type": CartTypes.enum_to_string(route.cart_type),
			"points": all_points_data,
			"segment_points": segment_points_data
		})

	return routes

func _vec2_to_dict(value: Vector2) -> Dictionary:
	return {
		"x": value.x,
		"y": value.y
	}

## Ensures the parent folder for the export path exists.
func _ensure_export_directory_exists() -> bool:
	var directory_path: String = export_json_path.get_base_dir()

	if DirAccess.dir_exists_absolute(directory_path):
		return true

	var error: Error = DirAccess.make_dir_recursive_absolute(directory_path)
	if error != OK:
		push_error("Failed to create export directory: %s" % directory_path)
		return false

	return true

## Builds a TicketMapData resource from the current editor state.
func _build_map_data_resource() -> TicketMapData:
	var normalization_offset: Vector2 = Vector2.ZERO
	if normalize_to_positive_coordinates:
		normalization_offset = _compute_normalization_offset()

	var map_data := TicketMapData.new()
	map_data.map_id = map_id
	map_data.map_size = map_size
	map_data.normalized = normalize_to_positive_coordinates
	map_data.normalization_offset = normalization_offset
	map_data.cities = _build_city_data_resources(normalization_offset)
	map_data.routes = _build_route_data_resources(normalization_offset)

	return map_data

## Builds TicketCityData resources from authored CityNodes.
func _build_city_data_resources(normalization_offset: Vector2) -> Array[TicketCityData]:
	var result: Array[TicketCityData] = []

	for child in cities_root.get_children():
		if not child is CityNode:
			continue

		var city: CityNode = child
		var city_data := TicketCityData.new()
		city_data.city_id = city.city_id
		city_data.display_name = city.display_name
		city_data.position = city.global_position + normalization_offset

		result.append(city_data)

	return result

## Builds TicketRouteData resources from authored RouteNodes.
func _build_route_data_resources(normalization_offset: Vector2) -> Array[TicketRouteData]:
	var result: Array[TicketRouteData] = []

	for child in routes_root.get_children():
		if not child is RouteNode:
			continue

		var route: RouteNode = child
		var route_data := TicketRouteData.new()

		route_data.node_name = route.name
		route_data.from_city_id = route.from_city.city_id
		route_data.to_city_id = route.to_city.city_id
		route_data.route_length = route.route_length
		route_data.cart_type = CartTypes.enum_to_string(route.cart_type)
		route_data.points = _build_route_points(route, normalization_offset)
		route_data.segment_points = _build_route_segment_point_resources(route, normalization_offset)

		result.append(route_data)

	return result

## Builds exported route points in global normalized space.
func _build_route_points(route: RouteNode, normalization_offset: Vector2) -> Array[Vector2]:
	var result: Array[Vector2] = []

	for local_point in route.points:
		var global_point: Vector2 = route.to_global(local_point) + normalization_offset
		result.append(global_point)

	return result

## Builds TicketSegmentPointData resources for the route's interior segment points.
func _build_route_segment_point_resources(route: RouteNode, normalization_offset: Vector2) -> Array[TicketSegmentPointData]:
	var result: Array[TicketSegmentPointData] = []
	var local_points: PackedVector2Array = route.points

	for i in range(1, local_points.size() - 1):
		var prev_global: Vector2 = route.to_global(local_points[i - 1]) + normalization_offset
		var current_global: Vector2 = route.to_global(local_points[i]) + normalization_offset
		var next_global: Vector2 = route.to_global(local_points[i + 1]) + normalization_offset

		var direction: Vector2 = next_global - prev_global
		var segment_data := TicketSegmentPointData.new()
		segment_data.index = i - 1
		segment_data.position = current_global
		segment_data.rotation_radians = direction.angle()

		result.append(segment_data)

	return result
