extends Element

const _on: Texture2D = preload("res://scenes/elements/inverter/inverter_on.png")
const _off: Texture2D = preload("res://scenes/elements/inverter/inverter_off.png")
const _on_off: Texture2D = preload("res://scenes/elements/inverter/inverter_on_off.png")
const _off_on: Texture2D = preload("res://scenes/elements/inverter/inverter_off_on.png")

var _relay_util: RelayDelayUtil = preload("res://utils/relay_delay_util.gd").new()

func _ready() -> void:
	type = Globals.Elements.INVERTER

	super()

func reset_energy():
	_relay_util.reset()
	_set_off_texture()
	super()

func _has_energy() -> bool:
	var in1: bool = _relay_util.run($Connectors/In.connected_has_energy())
	var in2: bool = $Connectors/In2.connected_has_energy()

	if in1 && in2:
		_off_texture = self._on
		return false
	elif in1:
		_off_texture = self._off_on
		return false
	elif in2:
		$Connectors/Out.set_energy(true)
		_on_texture = self._on_off
		return true
	else:
		_off_texture = self._off
		return false
