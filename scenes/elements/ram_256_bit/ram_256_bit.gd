extends Element

const _on: Texture2D = preload("res://scenes/elements/ram_256_bit/ram_256_bit_on.png")
const _off: Texture2D = preload("res://scenes/elements/ram_256_bit/ram_256_bit_off.png")

var _ram: Array = []

const _relay_util_class: RefCounted = preload("res://utils/relay_delay_util.gd")
var _relay_util1: RelayDelayUtil = _relay_util_class.new()
var _relay_util2: RelayDelayUtil = _relay_util_class.new()
var _relay_util3: RelayDelayUtil = _relay_util_class.new()
var _relay_util4: RelayDelayUtil = _relay_util_class.new()
var _relay_util5: RelayDelayUtil = _relay_util_class.new()
var _relay_util6: RelayDelayUtil = _relay_util_class.new()
var _relay_util7: RelayDelayUtil = _relay_util_class.new()
var _relay_util8: RelayDelayUtil = _relay_util_class.new()
var _relay_util9: RelayDelayUtil = _relay_util_class.new()
var _relay_util10: RelayDelayUtil = _relay_util_class.new()

func _ready() -> void:
	type = Globals.Elements.RAM_256_BIT
	add_to_group("Energy")
	# set ram
	_ram.resize(256)
	_ram.fill(0)
	super()

func reset_energy():
	_set_off_texture()
	_relay_util1.reset()
	_relay_util2.reset()
	_relay_util3.reset()
	_relay_util4.reset()
	_relay_util5.reset()
	_relay_util6.reset()
	_relay_util7.reset()
	_relay_util8.reset()
	_relay_util9.reset()
	_relay_util10.reset()
	super()

func _has_energy() -> bool:
	# write
	var in1: bool = _relay_util1.run($Connectors/In.connected_has_energy())
	# address
	var in2: bool = _relay_util2.run($Connectors/In2.connected_has_energy())
	var in3: bool = _relay_util3.run($Connectors/In3.connected_has_energy())
	var in4: bool = _relay_util4.run($Connectors/In4.connected_has_energy())
	var in5: bool = _relay_util5.run($Connectors/In5.connected_has_energy())
	var in6: bool = _relay_util6.run($Connectors/In6.connected_has_energy())
	var in7: bool = _relay_util7.run($Connectors/In7.connected_has_energy())
	var in8: bool = _relay_util8.run($Connectors/In8.connected_has_energy())
	var in9: bool = _relay_util9.run($Connectors/In9.connected_has_energy())
	# data
	var in10: bool = _relay_util10.run($Connectors/In10.connected_has_energy())

	var binary_str = "".join(
		PackedStringArray([in9, in8, in7, in6, in5, in4, in3, in2].map(func(x): return "1" if x else "0"))
	)
	var ram_index = binary_str.bin_to_int()

	if in1 && in10:
		# write
		_ram[ram_index] = 1
		$Connectors/Out.set_energy(true)
		return true
	elif in1:
		# reset
		_ram[ram_index] = 0
		$Connectors/Out.set_energy(false)
		return false
	# get
	else:
		if _ram[ram_index] == 1:
			$Connectors/Out.set_energy(true)
			return true
		$Connectors/Out.set_energy(false)
		return false
