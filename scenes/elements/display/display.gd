extends Element

var _on: Texture = preload("res://scenes/elements/display/display_on.png")
var _off: Texture = preload("res://scenes/elements/display/display_off.png")

func _ready() -> void:
	type = Globals.Elements.DISPLAY

func _has_energy() -> bool:
	for child in self._connectors_children:
		if child.type == Globals.Connectors.IN:
			var child_connected_area = child.connected_area
			if child_connected_area and child_connected_area.get_energy():
				return true
	return false
