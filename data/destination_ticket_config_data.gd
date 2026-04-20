@tool
extends Resource
class_name DestinationTicketConfigData

@export_category("Destination Ticket Config")
@export var enabled: bool = true
@export var points: int = 0
@export var from_city_id: String = ""
@export var to_city_id: String = ""
@export var image: Texture2D = null
