@tool
extends EditorPlugin

var plugin_screen: Control

func _enter_tree() -> void:
	plugin_screen = preload("res://addons/ticket_map_editor/ticket_game_config_editor.tscn").instantiate()
	EditorInterface.get_editor_main_screen().add_child(plugin_screen)
	plugin_screen.hide()

func _exit_tree() -> void:
	if plugin_screen != null:
		plugin_screen.queue_free()
		plugin_screen = null

func _has_main_screen() -> bool:
	return true

func _make_visible(visible: bool) -> void:
	if plugin_screen != null:
		plugin_screen.visible = visible

func _get_plugin_name() -> String:
	return "TicketMap"

func _get_plugin_icon() -> Texture2D:
	return EditorInterface.get_editor_theme().get_icon("Node", "EditorIcons")
