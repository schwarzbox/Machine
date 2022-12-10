extends Element

const _on: Texture = preload("res://scenes/elements/power_relay/power_relay_on.png")
const _off: Texture = preload("res://scenes/elements/power_relay/power_relay_off.png")

var relay_util: RelayDelayUtil = preload("res://scenes/utils/relay_delay_util.gd").new()

func _ready() -> void:
	self.type = Globals.Elements.POWER_RELAY
	self.add_to_group("Energy")

func reset_energy():
	self.relay_util.reset()
	self._set_off_texture()
	.reset_energy()

func __has_energy() -> bool:
	var in1 = self.relay_util.run($Connectors/In.connected_has_energy())

	if in1:
		$Connectors/Out.set_energy(true)
		return true
	else:
		return false
