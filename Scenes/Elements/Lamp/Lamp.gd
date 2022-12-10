extends Element

var _on: Texture = preload("res://scenes/elements/lamp/lamp_on.png")
var _off: Texture = preload("res://scenes/elements/lamp/lamp_off.png")

func _ready() -> void:
	self.type = Globals.Elements.LAMP

func __has_energy() -> bool:
	for child in self._connectors_children:
		if child.type == Globals.Connectors.IN:
			var child_connected_area = child.get_connected_area()
			if child_connected_area and child_connected_area.get_energy():
				return true
	return false
