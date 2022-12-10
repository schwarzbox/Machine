extends Element

const _on: Texture = preload("res://scenes/elements/power_inverter/power_inverter_on.png")
const _off: Texture = preload("res://scenes/elements/power_inverter/power_inverter_off.png")

var relay_util: RelayDelayUtil = preload("res://scenes/utils/relay_delay_util.gd").new()

func _ready() -> void:
	self.type = Globals.Elements.POWER_INVERTER
	self.add_to_group("Energy")

func reset_energy():
	self.relay_util.reset()
	self._set_off_texture()
	.reset_energy()

func __has_energy() -> bool:
	var in1 = self.relay_util.run($Connectors/In.connected_has_energy())

	if in1:
		self._off_texture = self._on
		return false
	else:
		$Connectors/Out.set_energy(true)
		self._on_texture = self._off
		return true

