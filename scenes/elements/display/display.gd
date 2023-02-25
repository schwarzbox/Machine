extends Element

var _on: Texture = preload("res://scenes/elements/display/display_on.png")
var _off: Texture = preload("res://scenes/elements/display/display_off.png")

func _ready() -> void:
	type = Globals.Elements.DISPLAY

func _has_energy() -> bool:
	for child in self._connectors_children:
		if child.type == Globals.Connectors.IN:
			if child.connected_has_energy():
				return true
	return false
