extends Element

const _on: Texture = preload("res://scenes/elements/adder_8_bit/adder_8_bit_on.png")
const _off: Texture = preload("res://scenes/elements/adder_8_bit/adder_8_bit_off.png")

const _relay_util_class: Resource = preload("res://utils/relay_delay_util.gd")
var _relay_utilC: RelayDelayUtil = _relay_util_class.new()
var _relay_utils: Array = []

onready var _connectors: Array = 	[
	$Connectors/In, $Connectors/In2, $Connectors/In3, $Connectors/In4,
	$Connectors/In5, $Connectors/In6, $Connectors/In7, $Connectors/In8,
	$Connectors/In9, $Connectors/In10, $Connectors/In11, $Connectors/In12,
	$Connectors/In13, $Connectors/In14, $Connectors/In15, $Connectors/In16
]

func _ready() -> void:
	type = Globals.Elements.ADDER_8_BIT

	for _i in range(_connectors.size()):
		_relay_utils.append(_relay_util_class.new())

func reset_energy() -> void:
	_relay_utilC.reset()
	for ru in _relay_utils:
		ru.reset()

	_set_off_texture()
	.reset_energy()

func _has_energy() -> bool:
	var inC: bool = _relay_utilC.run($Connectors/InC.connected_has_energy())

	var digit_1 = []
	for i in range(8):
		digit_1.append(
			_relay_utils[i].run(_connectors[i].connected_has_energy())
		)

	var digit_2 = []
	for i in range(8, 16):
		digit_2.append(
			_relay_utils[i].run(_connectors[i].connected_has_energy())
		)

	var bits = _add_binary(digit_1, digit_2, inC)
	# exclude carry_out bit
	for i in range(bits.size() - 1):
		var suffix = str(i + 1)
		var node_name = 'Connectors/Out'
		if i:
			node_name = node_name + suffix
		var connector = get_node(node_name)
		if bits[i] > 0:
			connector.set_energy(true)
		else:
			connector.set_energy(false)

	var carry_out = bits[-1]
	if carry_out == 1:
		$Connectors/OutC.set_energy(true)
		_on_texture = self._on
	else:
		$Connectors/OutC.set_energy(false)

	if 1 in bits || carry_out == 1:
		return true

	_off_texture = self._off
	return false

func _add_binary(digit_1: Array, digit_2: Array, carry_out: bool) -> Array:
	var size: int = digit_1.size()
	var bin_digit: Array = []

	for _i in range(size + 1):
		bin_digit.append(0)

	if carry_out:
		bin_digit[0] = 1

	for i in range(size):
		if digit_1[i] && digit_2[i] && bin_digit[i]:
			bin_digit[i] = 1
			bin_digit[i + 1] = 1
		elif (
				(digit_1[i] && digit_2[i])
				|| (digit_1[i] && bin_digit[i])
				|| (digit_2[i] && bin_digit[i])
			):
			bin_digit[i] = 0
			bin_digit[i + 1] = 1
		elif digit_1[i] || digit_2[i]:
			bin_digit[i] = 1

	return bin_digit

