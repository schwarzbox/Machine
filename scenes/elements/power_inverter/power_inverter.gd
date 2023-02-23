extends Element

const _on: Texture = preload("res://scenes/elements/power_inverter/power_inverter_on.png")
const _off: Texture = preload("res://scenes/elements/power_inverter/power_inverter_off.png")

var _relay_util: RelayDelayUtil = preload("res://utils/relay_delay_util.gd").new()

func _ready() -> void:
	type = Globals.Elements.POWER_INVERTER
	add_to_group("Energy")

func reset_energy():
	_relay_util.reset()
	_set_off_texture()
	.reset_energy()

func _has_energy() -> bool:
	var in1: bool = _relay_util.run($Connectors/In.connected_has_energy())

	if in1:
		_off_texture = self._on
		return false
	else:
		$Connectors/Out.set_energy(true)
		_on_texture = self._off
		return true

