@tool
extends Node
class_name EditorNameSync

@export_category("Naming")
@export var sync_city_names: bool = true
@export var sync_route_names: bool = true

@export_tool_button("Sync Node Names")
var sync_node_names_action := sync_node_names

@onready var editor: TicketMapEditor = get_parent() as TicketMapEditor

## Syncs CityNode and RouteNode editor names to readable unique names.
func sync_node_names() -> void:
	if not Engine.is_editor_hint():
		return

	if editor == null:
		return

	if sync_city_names:
		_sync_city_names()

	if sync_route_names:
		_sync_route_names()

func _sync_city_names() -> void:
	var used_names: Dictionary = {}

	for child in editor.get_node("Cities").get_children():
		if not child is CityNode:
			continue

		var city: CityNode = child
		var base_name: String = _sanitize_name(city.display_name.strip_edges())

		if base_name.is_empty():
			base_name = "City"

		city.name = _make_unique_name(base_name, used_names)
		city._refresh_visuals()

func _sync_route_names() -> void:
	var used_names: Dictionary = {}

	for child in editor.get_node("Routes").get_children():
		if not child is RouteNode:
			continue

		var route: RouteNode = child

		var from_name: String = "Unknown"
		var to_name: String = "Unknown"

		if route.from_city != null:
			from_name = _sanitize_name(route.from_city.display_name.strip_edges())
			if from_name.is_empty():
				from_name = "Unknown"

		if route.to_city != null:
			to_name = _sanitize_name(route.to_city.display_name.strip_edges())
			if to_name.is_empty():
				to_name = "Unknown"

		var base_name: String = "%s_to_%s" % [from_name, to_name]
		route.name = _make_unique_name(base_name, used_names)
		route._refresh_visuals()

func _make_unique_name(base_name: String, used_names: Dictionary) -> String:
	if not used_names.has(base_name):
		used_names[base_name] = 1
		return base_name

	used_names[base_name] += 1
	return "%s_%d" % [base_name, used_names[base_name]]

func _sanitize_name(value: String) -> String:
	var result: String = value.strip_edges()

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

	while "__" in result:
		result = result.replace("__", "_")

	result = result.trim_prefix("_")
	result = result.trim_suffix("_")

	return result
