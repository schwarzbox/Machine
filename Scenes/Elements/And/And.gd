extends Element

const _on: Texture = preload("res://Scenes/Elements/And/and_on.png")
const _off: Texture = preload("res://Scenes/Elements/And/and_off.png")
const _on_off: Texture = preload("res://Scenes/Elements/And/and_on_off.png")
const _off_on: Texture = preload("res://Scenes/Elements/And/and_off_on.png")

var relay_util1: RelayDelayUtil = preload("res://Scenes/Utils/RelayDelayUtil.gd").new()
var relay_util2: RelayDelayUtil = preload("res://Scenes/Utils/RelayDelayUtil.gd").new()

func _ready() -> void:
	self.type = Globals.ELEMENTS.AND

func reset_energy():
	self.relay_util1.reset()
	self.relay_util2.reset()
	self._set_off_texture()
	.reset_energy()

func __has_energy() -> bool:
	var in1 = self.relay_util1.run($Connectors/In.connected_has_energy())
	var in2 = self.relay_util2.run($Connectors/In2.connected_has_energy())

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
