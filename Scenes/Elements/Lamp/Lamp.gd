extends Element

var _on: Texture = preload("res://Scenes/Elements/Lamp/lamp_on.png")
var _off: Texture = preload("res://Scenes/Elements/Lamp/lamp_off.png")

func _ready() -> void:
	self.type = Globals.ELEMENTS.LAMP

func __has_energy() -> bool:
	for child in self._connectors_children:
		if child.type == Globals.CONNECTORS.IN:
			var child_connected_area = child.get_connected_area()
			if child_connected_area and child_connected_area.get_energy():
				return true
	return false
