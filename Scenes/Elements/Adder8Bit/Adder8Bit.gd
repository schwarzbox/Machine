extends Element

const _on: Texture = preload("res://Scenes/Elements/Adder8Bit/adder_8_bit_on.png")
const _off: Texture = preload("res://Scenes/Elements/Adder8Bit/adder_8_bit_off.png")

var relay_utilC: RelayDelayUtil = preload("res://Scenes/Utils/RelayDelayUtil.gd").new()
var relay_util1: RelayDelayUtil = preload("res://Scenes/Utils/RelayDelayUtil.gd").new()
var relay_util2: RelayDelayUtil = preload("res://Scenes/Utils/RelayDelayUtil.gd").new()
var relay_util3: RelayDelayUtil = preload("res://Scenes/Utils/RelayDelayUtil.gd").new()
var relay_util4: RelayDelayUtil = preload("res://Scenes/Utils/RelayDelayUtil.gd").new()
var relay_util5: RelayDelayUtil = preload("res://Scenes/Utils/RelayDelayUtil.gd").new()
var relay_util6: RelayDelayUtil = preload("res://Scenes/Utils/RelayDelayUtil.gd").new()
var relay_util7: RelayDelayUtil = preload("res://Scenes/Utils/RelayDelayUtil.gd").new()
var relay_util8: RelayDelayUtil = preload("res://Scenes/Utils/RelayDelayUtil.gd").new()
var relay_util9: RelayDelayUtil = preload("res://Scenes/Utils/RelayDelayUtil.gd").new()
var relay_util10: RelayDelayUtil = preload("res://Scenes/Utils/RelayDelayUtil.gd").new()
var relay_util11: RelayDelayUtil = preload("res://Scenes/Utils/RelayDelayUtil.gd").new()
var relay_util12: RelayDelayUtil = preload("res://Scenes/Utils/RelayDelayUtil.gd").new()
var relay_util13: RelayDelayUtil = preload("res://Scenes/Utils/RelayDelayUtil.gd").new()
var relay_util14: RelayDelayUtil = preload("res://Scenes/Utils/RelayDelayUtil.gd").new()
var relay_util15: RelayDelayUtil = preload("res://Scenes/Utils/RelayDelayUtil.gd").new()
var relay_util16: RelayDelayUtil = preload("res://Scenes/Utils/RelayDelayUtil.gd").new()

func _ready() -> void:
	self.type = Globals.ELEMENTS.ADDER_8_BIT

func reset_energy() -> void:
	self.relay_utilC.reset()
	self.relay_util1.reset()
	self.relay_util2.reset()
	self.relay_util3.reset()
	self.relay_util4.reset()
	self.relay_util5.reset()
	self.relay_util6.reset()
	self.relay_util7.reset()
	self.relay_util8.reset()
	self.relay_util9.reset()
	self.relay_util10.reset()
	self.relay_util11.reset()
	self.relay_util12.reset()
	self.relay_util13.reset()
	self.relay_util14.reset()
	self.relay_util15.reset()
	self.relay_util16.reset()

	self._set_off_texture()
	.reset_energy()

func _add_binary(d1: Array, d2: Array, ci: bool) -> Array:
	var size = d1.size()
	var bin_digit: Array = []
	for i in range(size + 1):
		bin_digit.append(0)
	if ci:
		bin_digit[0] = 1

	for i in range(size):
		if d1[i] && d2[i] && bin_digit[i]:
			bin_digit[i] = 1
			bin_digit[i + 1] = 1
		elif (
				(d1[i] && d2[i])
				|| (d1[i] && bin_digit[i])
				|| (d2[i] && bin_digit[i])
			):
			bin_digit[i] = 0
			bin_digit[i + 1] = 1
		elif d1[i] || d2[i]:
			bin_digit[i] = 1

	return bin_digit

func __has_energy() -> bool:
	var inC = self.relay_utilC.run($Connectors/InC.connected_has_energy())
	var in1 = self.relay_util1.run($Connectors/In.connected_has_energy())
	var in2 = self.relay_util2.run($Connectors/In2.connected_has_energy())
	var in3 = self.relay_util3.run($Connectors/In3.connected_has_energy())
	var in4 = self.relay_util4.run($Connectors/In4.connected_has_energy())
	var in5 = self.relay_util5.run($Connectors/In5.connected_has_energy())
	var in6 = self.relay_util6.run($Connectors/In6.connected_has_energy())
	var in7 = self.relay_util7.run($Connectors/In7.connected_has_energy())
	var in8 = self.relay_util8.run($Connectors/In8.connected_has_energy())

	var in9 = self.relay_util9.run($Connectors/In9.connected_has_energy())
	var in10 = self.relay_util10.run($Connectors/In10.connected_has_energy())
	var in11 = self.relay_util11.run($Connectors/In11.connected_has_energy())
	var in12 = self.relay_util12.run($Connectors/In12.connected_has_energy())
	var in13 = self.relay_util13.run($Connectors/In13.connected_has_energy())
	var in14 = self.relay_util14.run($Connectors/In14.connected_has_energy())
	var in15 = self.relay_util15.run($Connectors/In15.connected_has_energy())
	var in16 = self.relay_util16.run($Connectors/In16.connected_has_energy())

	var d1 = [in1, in2, in3, in4, in5, in6, in7, in8]
	var d2 = [in9, in10, in11, in12, in13, in14, in15, in16]

	var bits = self._add_binary(d1, d2, inC)

	for i in range(len(bits)-1):
		var suffix = str(i + 1)
		var node_name = 'Connectors/Out'
		if i:
			node_name = node_name + suffix
		var connector = self.get_node(node_name)
		if bits[i] > 0:
			connector.set_energy(true)
		else:
			connector.set_energy(false)

	var carry_out = bits[-1]
	if carry_out == 1:
		$Connectors/OutC.set_energy(true)
	else:
		$Connectors/OutC.set_energy(false)

	if 1 in bits or carry_out == 1:
		self._on_texture = self._on
		return true

	self._off_texture = self._off
	return false
