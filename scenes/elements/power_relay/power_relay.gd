extends Element

const _on: Texture2D = preload("res://scenes/elements/power_relay/power_relay_on.png")
const _off: Texture2D = preload("res://scenes/elements/power_relay/power_relay_off.png")

var _relay_util: RelayDelayUtil = preload("res://utils/relay_delay_util.gd").new()

func _ready() -> void:
	type = Globals.Elements.POWER_RELAY
	add_to_group("Energy")

	super()

func reset_energy():
	_relay_util.reset()
	_set_off_texture()
	super()

func _has_energy() -> bool:
	var in1: bool = _relay_util.run($Connectors/In.connected_has_energy())

	if in1:
		$Connectors/Out.set_energy(true)
		return true
	else:
		return false
