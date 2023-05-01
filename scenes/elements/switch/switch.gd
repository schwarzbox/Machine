extends Element

const _on: Texture2D = preload("res://scenes/elements/switch/switch_on.png")
const _off: Texture2D = preload("res://scenes/elements/switch/switch_off.png")
const _on_off: Texture2D = preload("res://scenes/elements/switch/switch_on_off.png")
const _off_on: Texture2D = preload("res://scenes/elements/switch/switch_off_on.png")

var _is_activated: bool = false

func _ready() -> void:
	type = Globals.Elements.SWITCH
	super()

func reset_energy():
	if _is_activated:
		_off_texture = self._off_on
	else:
		_off_texture = self._off
	super()

func switch() -> void:
	_is_activated = !_is_activated

func _has_energy() -> bool:
	if $Connectors/In.connected_has_energy():
		_off_texture = self._on_off
		if _is_activated:
			$Connectors/Out.set_energy(true)
			return true
	return false


