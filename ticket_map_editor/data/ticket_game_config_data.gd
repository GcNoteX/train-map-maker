@tool
extends Resource
class_name TicketGameConfigData

@export_category("Source Map")
@export var map_data: TicketMapData = null

@export_category("Game Rules")
@export var trains_per_player: int = 45

@export_category("Cards")
@export var transport_cards: Array[TransportCardConfigData] = []
@export var destination_tickets: Array[DestinationTicketConfigData] = []
