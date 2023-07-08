extends Element

const _on: Texture2D = preload("res://scenes/elements/ram_8_bit/ram_8_bit_on.png")
const _off: Texture2D = preload("res://scenes/elements/ram_8_bit/ram_8_bit_off.png")

var _ram: Array = []

const _relay_util_class: RefCounted = preload("res://utils/relay_delay_util.gd")
var _relay_util1: RelayDelayUtil = _relay_util_class.new()
var _relay_util2: RelayDelayUtil = _relay_util_class.new()
var _relay_util3: RelayDelayUtil = _relay_util_class.new()
var _relay_util4: RelayDelayUtil = _relay_util_class.new()
var _relay_util5: RelayDelayUtil = _relay_util_class.new()

func _ready() -> void:
	type = Globals.Elements.RAM_8_BIT
	add_to_group("Energy")
	# set ram
	_ram.resize(8)
	_ram.fill(0)
	super()

func reset_energy():
	_set_off_texture()
	_relay_util1.reset()
	_relay_util2.reset()
	_relay_util3.reset()
	_relay_util4.reset()
	_relay_util5.reset()
	super()

func _write(index: int, value: int):
	_ram[index] = value

func _has_energy() -> bool:
	# write
	var in1: bool = _relay_util1.run($Connectors/In.connected_has_energy())
	# address
	var in2: bool = _relay_util2.run($Connectors/In2.connected_has_energy())
	var in3: bool = _relay_util3.run($Connectors/In3.connected_has_energy())
	var in4: bool = _relay_util4.run($Connectors/In4.connected_has_energy())
	# data
	var in5: bool = _relay_util5.run($Connectors/In5.connected_has_energy())

	var binary_str = "".join(PackedStringArray([in4, in3, in2].map(func(x): return "1" if x else "0")))
	var ram_index = binary_str.bin_to_int()

	if in1 && in5:
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
