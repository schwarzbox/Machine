extends Element

const _on: Texture2D = preload("res://scenes/elements/switch/switch_on.png")
const _off: Texture2D = preload("res://scenes/elements/switch/switch_off.png")

var _is_activated: bool = false

func _ready() -> void:
	type = Globals.Elements.SWITCH
	super()

func _reset_energy():
	if _is_activated:
		_off_texture = self._on
	else:
		_off_texture = self._off

func reset_energy():
	_reset_energy()
	super()

func switch() -> void:
	_is_activated = !_is_activated

func _has_energy() -> bool:
	if $Connectors/In.connected_has_energy():
		_off_texture = self._off
		if _is_activated:
			$Connectors/Out.set_energy(true)
			return true
	else:
		_reset_energy()
	return false


