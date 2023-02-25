extends Element

var _on: Texture = preload("res://scenes/elements/switch/switch_on.png")
var _on_off: Texture = preload("res://scenes/elements/switch/switch_on_off.png")
var _off: Texture = preload("res://scenes/elements/switch/switch_off.png")

var _is_activated: bool = false

func _ready() -> void:
	type = Globals.Elements.SWITCH

func switch() -> void:
	_is_activated = !_is_activated
	_off_texture = _on_off if _is_activated else _off

func _has_energy() -> bool:
	if _is_activated:
		_off_texture = _on_off

		for child in _connectors_children:
			if child.type == Globals.Connectors.IN:
				if child.connected_has_energy():
					$Connectors/Out.set_energy(true)
					return true
		return false
	else:
		_off_texture = _off
		return false


