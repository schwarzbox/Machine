extends Element

const _on: Texture = preload("res://scenes/elements/half_adder/half_adder_on.png")
const _off: Texture = preload("res://scenes/elements/half_adder/half_adder_off.png")
const _on_off: Texture = preload("res://scenes/elements/half_adder/half_adder_on_off.png")
const _off_on: Texture = preload("res://scenes/elements/half_adder/half_adder_off_on.png")

var relay_util1: RelayDelayUtil = preload("res://utils/relay_delay_util.gd").new()
var relay_util2: RelayDelayUtil = preload("res://utils/relay_delay_util.gd").new()

func _ready() -> void:
	self.type = Globals.Elements.HALF_ADDER

func reset_energy() -> void:
	self.relay_util1.reset()
	self.relay_util2.reset()
	self._set_off_texture()
	.reset_energy()

func __has_energy() -> bool:
	var in1 = self.relay_util1.run($Connectors/In.connected_has_energy())
	var in2 = self.relay_util2.run($Connectors/In2.connected_has_energy())

	if in1 && in2:
		$Connectors/Out.set_energy(false)
		$Connectors/Out2.set_energy(true)
		self._on_texture = self._on
		return true
	elif in1:
		$Connectors/Out.set_energy(true)
		$Connectors/Out2.set_energy(false)
		self._on_texture = self._off_on
		return true
	elif in2:
		$Connectors/Out.set_energy(true)
		$Connectors/Out2.set_energy(false)
		self._on_texture = self._on_off
		return true
	else:
		self._off_texture = self._off
		return false
