@tool
extends RefCounted
class_name TicketGameConfigFactory

static func build_default_config(map_data: TicketMapData) -> TicketGameConfigData:
	var config := TicketGameConfigData.new()
	config.map_data = map_data
	config.trains_per_player = 45
	config.transport_cards = _build_default_transport_cards()
	config.destination_tickets = []
	return config

static func _build_default_transport_cards() -> Array[TransportCardConfigData]:
	var result: Array[TransportCardConfigData] = []

	for cart_type_name in CartTypes.playable_cart_type_strings():
		var entry := TransportCardConfigData.new()
		entry.cart_type = cart_type_name
		entry.card_count = 0
		entry.image = null
		result.append(entry)

	return result
