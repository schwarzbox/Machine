extends Element

var _on: Texture = preload("res://Scenes/Elements/Switch/switch_on.png")
var _on_off: Texture = preload("res://Scenes/Elements/Switch/switch_on_off.png")
var _off: Texture = preload("res://Scenes/Elements/Switch/switch_off.png")

var switched: bool = false

func _ready() -> void:
	self.type = Globals.ELEMENTS.SWITCH

func _unhandled_input(event: InputEvent) -> void:
	if (
		self.is_mouse_entered()
		&& event is InputEventMouseButton
		&& event.pressed
		&& not self._is_objects_scene_selected
	):
		if event.is_doubleclick():
			self.switched = not self.switched
			if self.switched:
				self._off_texture = self._on_off
			else:
				self._off_texture = self._off

func __has_energy() -> bool:
	if self.switched:
		self._off_texture = self._on_off

		for child in self._connectors_children:
			if child.type == Globals.CONNECTORS.IN:
				var child_connected_area = child.get_connected_area()
				if child_connected_area and child_connected_area.get_energy():
					$Connectors/Out.set_energy(true)
					return true
		return false
	else:
		self._off_texture = self._off
		return false


