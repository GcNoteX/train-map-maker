@tool
extends Control
class_name TicketGameConfigEditor

@export_category("Responsive UI")
@export var auto_scale_ui: bool = true
@export_range(0.4, 1.0, 0.05) var small_screen_scale: float = 0.70
@export_range(0.4, 1.0, 0.05) var medium_screen_scale: float = 0.85
@export var small_screen_width_threshold: int = 1000
@export var medium_screen_width_threshold: int = 1200

@onready var ui_scale_root: Control = %UIScaleRoot

@export_category("Data")
@export var config_data: TicketGameConfigData = null:
	set(value):
		config_data = value
		_refresh_ui_from_config()

@export_file("*.tres") var save_config_resource_path: String = "res://workspace/config_data/game_config.tres":
	set(value):
		save_config_resource_path = value
		if is_node_ready():
			_refresh_save_path_label()

@export_dir var export_folder_path: String = "res://workspace/exports"

@onready var image_file_dialog: FileDialog = %ImageFileDialog

var _pending_transport_image_target: TransportCardConfigData = null
var _pending_destination_image_target: DestinationTicketConfigData = null

@onready var config_resource_path_label: Label = %ConfigResourcePathLabel
@onready var load_config_button: Button = %LoadConfigButton
@onready var new_config_button: Button = %NewConfigButton

@onready var save_path_value_label: Label = %SavePathValueLabel
@onready var choose_save_path_button: Button = %ChooseSavePathButton

@onready var load_config_file_dialog: FileDialog = %LoadConfigFileDialog
@onready var save_config_file_dialog: FileDialog = %SaveConfigFileDialog

@onready var image_preview_popup: AcceptDialog = %ImagePreviewPopup
@onready var preview_path_label: Label = %PreviewPathLabel
@onready var preview_texture_rect: TextureRect = %PreviewTextureRect

@onready var source_map_value_label: Label = %SourceMapValueLabel
@onready var trains_spin_box: SpinBox = %TrainsSpinBox
@onready var destination_count_label: Label = %DestinationCountLabel
@onready var transport_cards_container: VBoxContainer = %TransportCardsContainer
@onready var destination_tickets_container: VBoxContainer = %DestinationTicketsContainer

@onready var create_default_config_button: Button = %CreateDefaultConfigButton
@onready var add_destination_ticket_button: Button = %AddDestinationTicketButton
@onready var save_config_resource_button: Button = %SaveConfigResourceButton

@onready var export_folder_value_label: Label = %ExportFolderValueLabel
@onready var choose_export_folder_button: Button = %ChooseExportFolderButton
@onready var export_pack_button: Button = %ExportPackButton
@onready var export_folder_dialog: FileDialog = %ExportFolderDialog

const TRANSPORT_CARD_ROW_SCENE: PackedScene = preload("uid://cxg0fistnkjqe")
const DESTINATION_TICKET_ROW_SCENE: PackedScene = preload("uid://bbsq8u3jd2sn5")
var _image_export_cache: Dictionary = {}

func _ready() -> void:
	if not load_config_button.pressed.is_connected(_on_load_config_pressed):
		load_config_button.pressed.connect(_on_load_config_pressed)

	if not new_config_button.pressed.is_connected(_on_new_config_pressed):
		new_config_button.pressed.connect(_on_new_config_pressed)

	if not choose_save_path_button.pressed.is_connected(_on_choose_save_path_pressed):
		choose_save_path_button.pressed.connect(_on_choose_save_path_pressed)

	if not load_config_file_dialog.file_selected.is_connected(_on_load_config_file_selected):
		load_config_file_dialog.file_selected.connect(_on_load_config_file_selected)

	if not save_config_file_dialog.file_selected.is_connected(_on_save_config_file_selected):
		save_config_file_dialog.file_selected.connect(_on_save_config_file_selected)
	
	if not create_default_config_button.pressed.is_connected(_on_create_default_config_pressed):
		create_default_config_button.pressed.connect(_on_create_default_config_pressed)

	if not add_destination_ticket_button.pressed.is_connected(_on_add_destination_ticket_pressed):
		add_destination_ticket_button.pressed.connect(_on_add_destination_ticket_pressed)

	if not save_config_resource_button.pressed.is_connected(_on_save_config_resource_pressed):
		save_config_resource_button.pressed.connect(_on_save_config_resource_pressed)

	if not trains_spin_box.value_changed.is_connected(_on_trains_per_player_changed):
		trains_spin_box.value_changed.connect(_on_trains_per_player_changed)
	
	if not image_file_dialog.file_selected.is_connected(_on_image_file_selected):
		image_file_dialog.file_selected.connect(_on_image_file_selected)
	
	if not choose_export_folder_button.pressed.is_connected(_on_choose_export_folder_pressed):
		choose_export_folder_button.pressed.connect(_on_choose_export_folder_pressed)

	if not export_pack_button.pressed.is_connected(_on_export_pack_pressed):
		export_pack_button.pressed.connect(_on_export_pack_pressed)

	if not export_folder_dialog.dir_selected.is_connected(_on_export_folder_selected):
		export_folder_dialog.dir_selected.connect(_on_export_folder_selected)
	
	_refresh_ui_from_config()
	_refresh_config_resource_label()
	_refresh_save_path_label()
	_refresh_export_folder_label()
	_apply_responsive_ui_scale()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_apply_responsive_ui_scale()

func _apply_responsive_ui_scale() -> void:
	if not is_node_ready():
		return

	if not auto_scale_ui:
		ui_scale_root.scale = Vector2.ONE
		return

	var viewport_size: Vector2 = get_viewport_rect().size
	var width: float = viewport_size.x

	var target_scale: float = 1.0

	if width < small_screen_width_threshold:
		target_scale = small_screen_scale
	elif width < medium_screen_width_threshold:
		target_scale = medium_screen_scale
	else:
		target_scale = 1.0

	ui_scale_root.scale = Vector2.ONE * target_scale

## Rebuilds the editor UI from the current config resource.
func _refresh_ui_from_config() -> void:
	if not is_node_ready():
		return

	_clear_container(transport_cards_container)
	_clear_container(destination_tickets_container)
	

	if config_data == null:
		source_map_value_label.text = "No config assigned"
		destination_count_label.text = "Destination Tickets: 0 total / 0 enabled"
		trains_spin_box.value = 45
		return

	trains_spin_box.value = config_data.trains_per_player

	if config_data.map_data != null:
		source_map_value_label.text = "%s" % config_data.map_data.map_id
	else:
		source_map_value_label.text = "No map data assigned"

	_build_transport_card_rows()
	_build_destination_ticket_rows()
	_refresh_destination_ticket_counter()
	_refresh_default_config_save_path_from_map_data()
	_refresh_config_resource_label()
	_refresh_save_path_label()

## Creates a fresh default config from the current map data if possible.
func _on_create_default_config_pressed() -> void:
	if config_data == null:
		config_data = TicketGameConfigData.new()

	if config_data.map_data == null:
		push_error("Cannot create default config without map_data assigned.")
		return

	var new_config: TicketGameConfigData = TicketGameConfigFactory.build_default_config(config_data.map_data)
	new_config.map_data = config_data.map_data
	config_data = new_config

	_refresh_ui_from_config()
	_refresh_default_config_save_path_from_map_data()
	_refresh_config_resource_label()
	_refresh_save_path_label()

## Adds a new destination ticket row/resource.
func _on_add_destination_ticket_pressed() -> void:
	if config_data == null:
		push_error("Assign or create a config first.")
		return

	if config_data.map_data == null:
		push_error("Assign map_data before adding destination tickets.")
		return

	var entry := DestinationTicketConfigData.new()
	entry.enabled = true
	entry.points = 0

	var city_ids: Array[String] = _get_city_ids_from_map_data()
	if city_ids.size() >= 1:
		entry.from_city_id = city_ids[0]
		entry.to_city_id = city_ids[0]

	config_data.destination_tickets.append(entry)
	_build_destination_ticket_rows()
	_refresh_destination_ticket_counter()

## Saves the config resource as a .tres, creating the folder/file if needed.
func _on_save_config_resource_pressed() -> void:
	if config_data == null:
		push_error("No config_data to save.")
		return

	if save_config_resource_path.is_empty():
		push_error("No save path selected.")
		return

	if not save_config_resource_path.ends_with(".tres"):
		save_config_resource_path += ".tres"

	if not _ensure_config_directory_exists():
		return

	var file_already_exists: bool = FileAccess.file_exists(save_config_resource_path)

	var result: Error = ResourceSaver.save(config_data, save_config_resource_path)
	if result != OK:
		push_error("Failed to save config resource: %s (error code %d)" % [save_config_resource_path, result])
		return

	if file_already_exists:
		print("Updated config resource at: %s" % save_config_resource_path)
	else:
		print("Created new config resource at: %s" % save_config_resource_path)

	_refresh_config_resource_label()
	_refresh_save_path_label()

func _on_trains_per_player_changed(value: float) -> void:
	if config_data == null:
		return

	config_data.trains_per_player = int(value)

## Builds rows for each transport card config entry.
func _build_transport_card_rows() -> void:
	if config_data == null:
		return

	_clear_container(transport_cards_container)

	for entry in config_data.transport_cards:
		var row: TransportCardRow = TRANSPORT_CARD_ROW_SCENE.instantiate()
		transport_cards_container.add_child(row)
		row.bind_data(entry)
		row.image_pick_requested.connect(_on_transport_image_pick_requested)
		row.image_clear_requested.connect(_on_transport_image_clear_requested)
		row.image_preview_requested.connect(_on_transport_image_preview_requested)
		
## Builds rows for each destination ticket config entry.
func _build_destination_ticket_rows() -> void:
	if config_data == null:
		return

	_clear_container(destination_tickets_container)

	var city_ids: Array[String] = _get_city_ids_from_map_data()
	var warning_map: Dictionary = _build_destination_ticket_warning_map()

	for i in range(config_data.destination_tickets.size()):
		var entry: DestinationTicketConfigData = config_data.destination_tickets[i]

		var row_instance: Node = DESTINATION_TICKET_ROW_SCENE.instantiate()
		var row: DestinationTicketRow = row_instance as DestinationTicketRow

		if row == null:
			push_error("DestinationTicketRow scene did not instantiate as DestinationTicketRow.")
			continue

		destination_tickets_container.add_child(row)
		row.bind_data(entry, city_ids)
		row.set_row_number(i + 1)

		if warning_map.has(entry):
			row.set_warning_state(true, warning_map[entry])
		else:
			row.set_warning_state(false)

		row.remove_requested.connect(_on_destination_ticket_remove_requested.bind(entry))
		row.image_pick_requested.connect(_on_destination_image_pick_requested)
		row.image_clear_requested.connect(_on_destination_image_clear_requested)
		row.data_changed.connect(_on_destination_ticket_data_changed)
		row.image_preview_requested.connect(_on_destination_image_preview_requested)

func _on_destination_ticket_data_changed() -> void:
	_build_destination_ticket_rows()
	_refresh_destination_ticket_counter()

func _on_transport_image_preview_requested(data: TransportCardConfigData) -> void:
	if data == null or data.image == null:
		return

	_show_image_preview(data.image, data.image.resource_path)

func _on_destination_image_preview_requested(data: DestinationTicketConfigData) -> void:
	if data == null or data.image == null:
		return

	_show_image_preview(data.image, data.image.resource_path)

func _show_image_preview(texture: Texture2D, path: String) -> void:
	preview_texture_rect.texture = texture
	preview_path_label.text = path if not path.is_empty() else "No path"
	image_preview_popup.popup_centered_ratio(0.6)

func _on_destination_ticket_remove_requested(entry: DestinationTicketConfigData) -> void:
	if config_data == null:
		return

	config_data.destination_tickets.erase(entry)
	_build_destination_ticket_rows()
	_refresh_destination_ticket_counter()

func _refresh_destination_ticket_counter() -> void:
	if config_data == null:
		destination_count_label.text = "Destination Tickets: 0 total / 0 enabled"
		return

	var total: int = config_data.destination_tickets.size()
	var enabled_count: int = 0

	for entry in config_data.destination_tickets:
		if entry.enabled:
			enabled_count += 1

	destination_count_label.text = "Destination Tickets: %d total / %d enabled" % [total, enabled_count]

func _get_city_ids_from_map_data() -> Array[String]:
	var result: Array[String] = []

	if config_data == null or config_data.map_data == null:
		return result

	for city_data in config_data.map_data.cities:
		result.append(city_data.city_id)

	return result

func _clear_container(container: Node) -> void:
	for child in container.get_children():
		child.queue_free()

## Ensures the parent folder for the config resource path exists.
func _ensure_config_directory_exists() -> bool:
	var directory_path: String = save_config_resource_path.get_base_dir()

	if DirAccess.dir_exists_absolute(directory_path):
		return true

	var error: Error = DirAccess.make_dir_recursive_absolute(directory_path)
	if error != OK:
		push_error("Failed to create config directory: %s (error code %d)" % [directory_path, error])
		return false

	return true

#region ImageSelection
func _on_transport_image_pick_requested(data: TransportCardConfigData) -> void:
	if data == null:
		return

	_pending_transport_image_target = data
	_pending_destination_image_target = null
	image_file_dialog.popup_centered_ratio()

func _on_transport_image_clear_requested(data: TransportCardConfigData) -> void:
	if data == null:
		return

	data.image = null
	_build_transport_card_rows()

func _on_destination_image_pick_requested(data: DestinationTicketConfigData) -> void:
	if data == null:
		return

	_pending_destination_image_target = data
	_pending_transport_image_target = null
	image_file_dialog.popup_centered_ratio()

func _on_destination_image_clear_requested(data: DestinationTicketConfigData) -> void:
	if data == null:
		return

	data.image = null
	_build_destination_ticket_rows()
	_refresh_destination_ticket_counter()

func _on_image_file_selected(path: String) -> void:
	var texture: Texture2D = load(path) as Texture2D
	if texture == null:
		push_error("Selected file is not a valid Texture2D: %s" % path)
		_clear_pending_image_targets()
		return

	if _pending_transport_image_target != null:
		_pending_transport_image_target.image = texture
		_build_transport_card_rows()

	elif _pending_destination_image_target != null:
		_pending_destination_image_target.image = texture
		_build_destination_ticket_rows()
		_refresh_destination_ticket_counter()

	_clear_pending_image_targets()

func _clear_pending_image_targets() -> void:
	_pending_transport_image_target = null
	_pending_destination_image_target = null
#endregion

func _refresh_config_resource_label() -> void:
	if not is_node_ready():
		return

	if config_data == null:
		config_resource_path_label.text = "No config loaded"
		return

	if not save_config_resource_path.is_empty():
		config_resource_path_label.text = save_config_resource_path
	elif not config_data.resource_path.is_empty():
		config_resource_path_label.text = config_data.resource_path
	else:
		config_resource_path_label.text = "Unsaved config resource"

func _refresh_save_path_label() -> void:
	if not is_node_ready():
		return

	save_path_value_label.text = save_config_resource_path if not save_config_resource_path.is_empty() else "No save path selected"

func _on_load_config_pressed() -> void:
	load_config_file_dialog.popup_centered_ratio()

func _on_new_config_pressed() -> void:
	var new_config := TicketGameConfigData.new()

	if config_data != null and config_data.map_data != null:
		new_config.map_data = config_data.map_data
	elif config_data == null:
		new_config.map_data = null

	config_data = new_config
	_refresh_ui_from_config()
	_refresh_default_config_save_path_from_map_data()
	_refresh_config_resource_label()
	_refresh_save_path_label()

func _on_choose_save_path_pressed() -> void:
	save_config_file_dialog.current_file = save_config_resource_path.get_file()
	save_config_file_dialog.current_dir = save_config_resource_path.get_base_dir()
	save_config_file_dialog.popup_centered_ratio()

func _on_load_config_file_selected(path: String) -> void:
	var loaded_resource: Resource = load(path)
	var loaded_config: TicketGameConfigData = loaded_resource as TicketGameConfigData

	if loaded_config == null:
		push_error("Selected file is not a TicketGameConfigData resource: %s" % path)
		return

	config_data = loaded_config
	save_config_resource_path = path
	_refresh_ui_from_config()
	_refresh_config_resource_label()
	_refresh_save_path_label()

func _on_save_config_file_selected(path: String) -> void:
	if not path.ends_with(".tres"):
		path += ".tres"

	save_config_resource_path = path
	_refresh_save_path_label()


func _get_destination_ticket_pair_key(from_city_id: String, to_city_id: String) -> String:
	var a: String = from_city_id
	var b: String = to_city_id

	if a > b:
		var temp: String = a
		a = b
		b = temp

	return "%s|%s" % [a, b]

func _build_destination_ticket_warning_map() -> Dictionary:
	var warning_map: Dictionary = {}
	var pair_counts: Dictionary = {}

	if config_data == null:
		return warning_map

	for entry in config_data.destination_tickets:
		if entry == null or not entry.enabled:
			continue

		if entry.from_city_id == entry.to_city_id and not entry.from_city_id.is_empty():
			warning_map[entry] = "Destination ticket cannot point to the same city."

		var pair_key: String = _get_destination_ticket_pair_key(entry.from_city_id, entry.to_city_id)
		if not pair_counts.has(pair_key):
			pair_counts[pair_key] = 0
		pair_counts[pair_key] += 1

	for entry in config_data.destination_tickets:
		if entry == null or not entry.enabled:
			continue

		var pair_key: String = _get_destination_ticket_pair_key(entry.from_city_id, entry.to_city_id)
		if pair_counts.get(pair_key, 0) > 1:
			if warning_map.has(entry):
				warning_map[entry] += " Duplicate city combination with another row."
			else:
				warning_map[entry] = "Duplicate city combination with another row."

	return warning_map

func _refresh_default_config_save_path_from_map_data() -> void:
	if not is_node_ready():
		return

	if config_data == null or config_data.map_data == null:
		return

	var safe_map_id: String = _sanitize_file_name(config_data.map_data.map_id)
	if safe_map_id.is_empty():
		safe_map_id = "ticket_map"

	var default_save_path: String = "res://workspace/config_data/%s_game_config.tres" % safe_map_id

	if _should_auto_update_config_save_path():
		save_config_resource_path = default_save_path

func _should_auto_update_config_save_path() -> bool:
	return (
		save_config_resource_path.is_empty()
		or save_config_resource_path == "res://workspace/config_data/game_config.tres"
		or save_config_resource_path == "res://workspace/config_data/ticket_map_game_config.tres"
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

func _refresh_export_folder_label() -> void:
	if not is_node_ready():
		return

	export_folder_value_label.text = export_folder_path if not export_folder_path.is_empty() else "No export folder selected"

func _on_choose_export_folder_pressed() -> void:
	export_folder_dialog.current_dir = export_folder_path if not export_folder_path.is_empty() else "res://workspace/exports"
	export_folder_dialog.popup_centered_ratio()

func _on_export_folder_selected(dir_path: String) -> void:
	export_folder_path = dir_path
	_refresh_export_folder_label()

func _on_export_pack_pressed() -> void:
	if config_data == null:
		push_error("No config_data assigned.")
		return

	if config_data.map_data == null:
		push_error("No map_data assigned to config_data.")
		return

	if export_folder_path.is_empty():
		push_error("No export folder selected.")
		return

	var safe_map_id: String = _sanitize_file_name(config_data.map_data.map_id)
	if safe_map_id.is_empty():
		safe_map_id = "ticket_map"

	var pack_root: String = export_folder_path.path_join("%s_export" % safe_map_id)
	var img_dir: String = pack_root.path_join("img")
	var config_json_path: String = pack_root.path_join("config.json")

	if not _ensure_directory_exists(pack_root):
		return

	if not _ensure_directory_exists(img_dir):
		return

	_image_export_cache.clear()

	var export_dict: Dictionary = _build_final_export_dictionary(img_dir)

	var file: FileAccess = FileAccess.open(config_json_path, FileAccess.WRITE)
	if file == null:
		push_error("Failed to open export json path: %s" % config_json_path)
		return

	file.store_string(JSON.stringify(export_dict, "\t"))
	file.close()

	print("Exported final config pack to: %s" % pack_root)

func _ensure_directory_exists(path: String) -> bool:
	if DirAccess.dir_exists_absolute(path):
		return true

	var error: Error = DirAccess.make_dir_recursive_absolute(path)
	if error != OK:
		push_error("Failed to create directory: %s (error code %d)" % [path, error])
		return false

	return true

func _build_final_export_dictionary(img_dir: String) -> Dictionary:
	return {
		"map": _build_map_export_dictionary(config_data.map_data),
		"game_config": {
			"trains_per_player": config_data.trains_per_player,
			"transport_cards": _build_transport_card_export_array(img_dir),
			"destination_tickets": _build_destination_ticket_export_array(img_dir)
		}
	}

func _build_map_export_dictionary(map_data: TicketMapData) -> Dictionary:
	var cities: Array = []
	for city_data in map_data.cities:
		cities.append({
			"id": city_data.city_id,
			"display_name": city_data.display_name,
			"position": _vec2_to_dict(city_data.position)
		})

	var routes: Array = []
	for route_data in map_data.routes:
		var points: Array = []
		for point in route_data.points:
			points.append(_vec2_to_dict(point))

		var segment_points: Array = []
		for segment_data in route_data.segment_points:
			segment_points.append({
				"index": segment_data.index,
				"position": _vec2_to_dict(segment_data.position),
				"rotation_radians": segment_data.rotation_radians
			})

		routes.append({
			"node_name": route_data.node_name,
			"from_city_id": route_data.from_city_id,
			"to_city_id": route_data.to_city_id,
			"route_length": route_data.route_length,
			"cart_type": route_data.cart_type,
			"points": points,
			"segment_points": segment_points
		})

	return {
		"map_id": map_data.map_id,
		"map_size": _vec2_to_dict(map_data.map_size),
		"normalized": map_data.normalized,
		"normalization_offset": _vec2_to_dict(map_data.normalization_offset),
		"cities": cities,
		"routes": routes
	}
func _build_transport_card_export_array(img_dir: String) -> Array:
	var result: Array = []

	for entry in config_data.transport_cards:
		var relative_image_path: String = ""
		if entry.image != null:
			relative_image_path = _export_texture_once(
				entry.image,
				img_dir,
				"transport_%s" % entry.cart_type.to_lower()
			)

		result.append({
			"cart_type": entry.cart_type,
			"card_count": entry.card_count,
			"image_path": relative_image_path
		})

	return result

func _build_destination_ticket_export_array(img_dir: String) -> Array:
	var result: Array = []
	var enabled_index: int = 1

	for entry in config_data.destination_tickets:
		if not entry.enabled:
			continue

		var relative_image_path: String = ""
		if entry.image != null:
			relative_image_path = _export_texture_once(
				entry.image,
				img_dir,
				"destination_%02d" % enabled_index
			)

		result.append({
			"points": entry.points,
			"from_city_id": entry.from_city_id,
			"to_city_id": entry.to_city_id,
			"image_path": relative_image_path
		})

		enabled_index += 1

	return result

func _export_texture_once(texture: Texture2D, img_dir: String, target_base_name: String) -> String:
	if texture == null:
		return ""

	var source_path: String = texture.resource_path
	if source_path.is_empty():
		push_error("Texture has no resource_path and cannot be exported.")
		return ""

	if _image_export_cache.has(source_path):
		return _image_export_cache[source_path]

	var extension: String = source_path.get_extension().to_lower()
	if extension.is_empty():
		extension = "png"

	var file_name: String = "%s.%s" % [target_base_name, extension]
	var target_path: String = img_dir.path_join(file_name)
	var relative_path: String = "img/%s" % file_name

	# Make sure we do not overwrite a different image with the same target name.
	var suffix: int = 2
	while FileAccess.file_exists(target_path):
		var existing_relative_path: String = "img/%s" % target_path.get_file()

		# If the existing target path is already the cached output for this same source, reuse it.
		if _image_export_cache.has(source_path) and _image_export_cache[source_path] == existing_relative_path:
			return existing_relative_path

		file_name = "%s_%d.%s" % [target_base_name, suffix, extension]
		target_path = img_dir.path_join(file_name)
		relative_path = "img/%s" % file_name
		suffix += 1

	var source_file: FileAccess = FileAccess.open(source_path, FileAccess.READ)
	if source_file == null:
		push_error("Failed to open source image: %s" % source_path)
		return ""

	var bytes: PackedByteArray = source_file.get_buffer(source_file.get_length())
	source_file.close()

	var target_file: FileAccess = FileAccess.open(target_path, FileAccess.WRITE)
	if target_file == null:
		push_error("Failed to open target image path: %s" % target_path)
		return ""

	target_file.store_buffer(bytes)
	target_file.close()

	_image_export_cache[source_path] = relative_path
	return relative_path

func _vec2_to_dict(value: Vector2) -> Dictionary:
	return {
		"x": value.x,
		"y": value.y
	}
