extends RefCounted
class_name CartTypes

enum CartType {
	NONE,
	PURPLE,
	BLUE,
	ORANGE,
	WHITE,
	GREEN,
	YELLOW,
	BLACK,
	RED,
	GRAY # Any Color in actual implementation.
}

static func to_color(cart_type: CartType) -> Color:
	match cart_type:
		CartType.PURPLE:
			return Color(0.737, 0.0, 0.737, 1.0)
		CartType.BLUE:
			return Color(0.2, 0.4, 0.9, 1.0)
		CartType.ORANGE:
			return Color(0.95, 0.55, 0.2, 1.0)
		CartType.WHITE:
			return Color(0.95, 0.95, 0.95, 1.0)
		CartType.GREEN:
			return Color(0.2, 0.7, 0.3, 1.0)
		CartType.YELLOW:
			return Color(0.95, 0.85, 0.2, 1.0)
		CartType.BLACK:
			return Color(0.15, 0.15, 0.15, 1.0)
		CartType.RED:
			return Color(0.85, 0.2, 0.2, 1.0)
		CartType.GRAY:
			return Color(0.592, 0.651, 0.678)
		_:
			return Color(0.85, 0.851, 0.844, 1.0)

static func enum_to_string(cart_type: CartType) -> String:
	match cart_type:
		CartType.NONE:
			return "NONE"
		CartType.PURPLE:
			return "PURPLE"
		CartType.BLUE:
			return "BLUE"
		CartType.ORANGE:
			return "ORANGE"
		CartType.WHITE:
			return "WHITE"
		CartType.GREEN:
			return "GREEN"
		CartType.YELLOW:
			return "YELLOW"
		CartType.BLACK:
			return "BLACK"
		CartType.RED:
			return "RED"
		CartType.GRAY:
			return "GRAY"
		_:
			return "NONE"

static func color_to_dict(color: Color) -> Dictionary:
	return {
		"r": color.r,
		"g": color.g,
		"b": color.b,
		"a": color.a,
		"hex": color.to_html()
	}

static func all_cart_type_strings() -> Array[String]:
	return [
		"NONE",
		"PURPLE",
		"BLUE",
		"ORANGE",
		"WHITE",
		"GREEN",
		"YELLOW",
		"BLACK",
		"RED",
		"GRAY"
	]

static func playable_cart_type_strings() -> Array[String]:
	return [
		"PURPLE",
		"BLUE",
		"ORANGE",
		"WHITE",
		"GREEN",
		"YELLOW",
		"BLACK",
		"RED",
		"GRAY"
	]
