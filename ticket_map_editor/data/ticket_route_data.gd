@tool
extends Resource
class_name TicketRouteData

@export_category("Route Data")
@export var node_name: String = ""
@export var from_city_id: String = ""
@export var to_city_id: String = ""
@export var route_length: int = 0
@export var cart_type: String = ""

@export_category("Geometry")
@export var points: Array[Vector2] = []
@export var segment_points: Array[TicketSegmentPointData] = []
