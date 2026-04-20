@tool
extends HBoxContainer
class_name DestinationTicketRow

signal remove_requested
signal data_changed
signal image_pick_requested(data: DestinationTicketConfigData)
signal image_clear_requested(data: DestinationTicketConfigData)
signal image_preview_requested(data: DestinationTicketConfigData)

@onready var image_preview_button: Button = %ImagePreviewButton
@onready var row_number_label: Label = %RowNumberLabel
@onready var enabled_check_box: CheckBox = %EnabledCheckBox
@onready var points_spin_box: SpinBox = %PointsSpinBox
@onready var from_city_option_button: OptionButton = %FromCityOptionButton
@onready var to_city_option_button: OptionButton = %ToCityOptionButton
@onready var image_path_label: Label = %ImagePathLabel
@onready var select_image_button: Button = %SelectImageButton
@onready var clear_image_button: Button = %ClearImageButton
@onready var remove_button: Button = %RemoveButton

var _data: DestinationTicketConfigData = null
var _city_ids: Array[String] = []

func _ready() -> void:
	
	if not image_preview_button.pressed.is_connected(_on_image_preview_pressed):
		image_preview_button.pressed.connect(_on_image_preview_pressed)
	if not enabled_check_box.toggled.is_connected(_on_enabled_toggled):
		enabled_check_box.toggled.connect(_on_enabled_toggled)

	if not points_spin_box.value_changed.is_connected(_on_points_changed):
		points_spin_box.value_changed.connect(_on_points_changed)

	if not from_city_option_button.item_selected.is_connected(_on_from_city_selected):
		from_city_option_button.item_selected.connect(_on_from_city_selected)

	if not to_city_option_button.item_selected.is_connected(_on_to_city_selected):
		to_city_option_button.item_selected.connect(_on_to_city_selected)

	if not remove_button.pressed.is_connected(_on_remove_pressed):
		remove_button.pressed.connect(_on_remove_pressed)

	if not select_image_button.pressed.is_connected(_on_select_image_pressed):
		select_image_button.pressed.connect(_on_select_image_pressed)

	if not clear_image_button.pressed.is_connected(_on_clear_image_pressed):
		clear_image_button.pressed.connect(_on_clear_image_pressed)

func bind_data(data: DestinationTicketConfigData, city_ids: Array[String]) -> void:
	_data = data
	_city_ids = city_ids.duplicate()

	_rebuild_city_option_buttons()

	if _data == null:
		row_number_label.text = ""
		enabled_check_box.button_pressed = false
		points_spin_box.value = 0
		image_path_label.text = "No image"
		_refresh_preview_button()
		return

	enabled_check_box.button_pressed = _data.enabled
	points_spin_box.value = _data.points
	image_path_label.text = _data.image.resource_path if _data.image != null else "No image"

	_select_city_option(from_city_option_button, _data.from_city_id)
	_select_city_option(to_city_option_button, _data.to_city_id)
	_refresh_preview_button()

func set_row_number(display_index: int) -> void:
	row_number_label.text = "%d." % display_index

func _rebuild_city_option_buttons() -> void:
	from_city_option_button.clear()
	to_city_option_button.clear()

	for city_id in _city_ids:
		from_city_option_button.add_item(city_id)
		to_city_option_button.add_item(city_id)

func _select_city_option(button: OptionButton, city_id: String) -> void:
	for i in range(button.item_count):
		if button.get_item_text(i) == city_id:
			button.select(i)
			return

	if button.item_count > 0:
		button.select(0)

func _on_enabled_toggled(toggled_on: bool) -> void:
	if _data == null:
		return

	_data.enabled = toggled_on
	data_changed.emit()

func _on_points_changed(value: float) -> void:
	if _data == null:
		return

	_data.points = int(value)
	data_changed.emit()

func _on_from_city_selected(index: int) -> void:
	if _data == null:
		return

	_data.from_city_id = from_city_option_button.get_item_text(index)
	data_changed.emit()

func _on_to_city_selected(index: int) -> void:
	if _data == null:
		return

	_data.to_city_id = to_city_option_button.get_item_text(index)
	data_changed.emit()

func _on_select_image_pressed() -> void:
	if _data == null:
		return

	image_pick_requested.emit(_data)

func _on_clear_image_pressed() -> void:
	if _data == null:
		return

	image_clear_requested.emit(_data)

func _on_remove_pressed() -> void:
	remove_requested.emit()

func _refresh_preview_button() -> void:
	if _data == null or _data.image == null:
		image_preview_button.icon = null
		image_preview_button.text = "No Img"
		return

	image_preview_button.icon = _data.image
	image_preview_button.text = ""

func _on_image_preview_pressed() -> void:
	if _data == null or _data.image == null:
		print("No Image")
		return

	image_preview_requested.emit(_data)

func set_warning_state(is_warning: bool, warning_text: String = "") -> void:
	if is_warning:
		modulate = Color(1.0, 1.0, 0.6, 1.0)
		tooltip_text = warning_text
	else:
		modulate = Color(1, 1, 1, 1)
		tooltip_text = ""
