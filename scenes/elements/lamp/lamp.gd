extends Element

const _on: Texture = preload("res://scenes/elements/lamp/lamp_on.png")
const _off: Texture = preload("res://scenes/elements/lamp/lamp_off.png")

func _ready() -> void:
	type = Globals.Elements.LAMP

func _has_energy() -> bool:
	for child in _connectors_children:
		if child.type == Globals.Connectors.IN:
			var child_connected_area = child.connected_area
			if child_connected_area && child_connected_area.get_energy():
				return true
	return false
