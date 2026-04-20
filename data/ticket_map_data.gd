@tool
extends Resource
class_name TicketMapData

@export_category("Map Data")
@export var map_id: String = ""
@export var map_size: Vector2 = Vector2.ZERO
@export var normalized: bool = true
@export var normalization_offset: Vector2 = Vector2.ZERO

@export_category("Content")
@export var cities: Array[TicketCityData] = []
@export var routes: Array[TicketRouteData] = []
