@tool
extends HBoxContainer
class_name TransportCardRow

signal image_pick_requested(data: TransportCardConfigData)
signal image_clear_requested(data: TransportCardConfigData)
signal image_preview_requested(data: TransportCardConfigData)

@onready var cart_type_label: Label = %CartTypeLabel
@onready var card_count_spin_box: SpinBox = %CardCountSpinBox
@onready var image_path_label: Label = %ImagePathLabel
@onready var select_image_button: Button = %SelectImageButton
@onready var clear_image_button: Button = %ClearImageButton
@onready var image_preview_button: Button = %ImagePreviewButton

var _data: TransportCardConfigData = null

func _ready() -> void:
	if not image_preview_button.pressed.is_connected(_on_image_preview_pressed):
		image_preview_button.pressed.connect(_on_image_preview_pressed)
	
	if not card_count_spin_box.value_changed.is_connected(_on_card_count_changed):
		card_count_spin_box.value_changed.connect(_on_card_count_changed)

	if not select_image_button.pressed.is_connected(_on_select_image_pressed):
		select_image_button.pressed.connect(_on_select_image_pressed)

	if not clear_image_button.pressed.is_connected(_on_clear_image_pressed):
		clear_image_button.pressed.connect(_on_clear_image_pressed)

func bind_data(data: TransportCardConfigData) -> void:
	_data = data

	if _data == null:
		cart_type_label.text = ""
		card_count_spin_box.value = 0
		image_path_label.text = "No image"
		_refresh_preview_button()
		return

	cart_type_label.text = _data.cart_type
	card_count_spin_box.value = _data.card_count
	image_path_label.text = _data.image.resource_path if _data.image != null else "No image"
	_refresh_preview_button()

func _on_card_count_changed(value: float) -> void:
	if _data == null:
		return

	_data.card_count = int(value)

func _on_select_image_pressed() -> void:
	if _data == null:
		return

	image_pick_requested.emit(_data)

func _on_clear_image_pressed() -> void:
	if _data == null:
		return

	image_clear_requested.emit(_data)


func _refresh_preview_button() -> void:
	if _data == null or _data.image == null:
		image_preview_button.icon = null
		image_preview_button.text = "No Img"
		return

	image_preview_button.icon = _data.image
	image_preview_button.text = ""

func _on_image_preview_pressed() -> void:
	if _data == null or _data.image == null:
		return

	image_preview_requested.emit(_data)
