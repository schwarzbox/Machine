extends Element

const _on: Texture = preload("res://Scenes/Elements/Relay/relay_on.png")
const _off: Texture = preload("res://Scenes/Elements/Relay/relay_off.png")
const _on_off: Texture = preload("res://Scenes/Elements/Relay/relay_on_off.png")
const _off_on: Texture = preload("res://Scenes/Elements/Relay/relay_off_on.png")

var relay_util: RelayDelayUtil = preload("res://Scenes/Utils/RelayDelayUtil.gd").new()

func _ready() -> void:
	self.type = Globals.ELEMENTS.RELAY

func reset_energy():
	self.relay_util.reset()
	self._set_off_texture()
	.reset_energy()

func __has_energy() -> bool:
	var in1 = self.relay_util.run($Connectors/In.connected_has_energy())
	var in2 = $Connectors/In2.connected_has_energy()

	if in1 and in2:
		$Connectors/Out.set_energy(true)
		return true
	elif in1:
		self._off_texture = self._off_on
		return false
	elif in2:
		self._off_texture = self._on_off
		return false
	else:
		self._off_texture = self._off
		return false

