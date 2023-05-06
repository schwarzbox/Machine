extends Element

const _on: Texture2D = preload("res://scenes/elements/ram_8_bit/ram_8_bit_on.png")
const _off: Texture2D = preload("res://scenes/elements/ram_8_bit/ram_8_bit_off.png")

# input off
const _off_off_off_off_on: Texture2D = preload(
	"res://scenes/elements/ram_8_bit/ram_8_bit_off_off_off_off_on.png"
)
const _on_off_off_off_off: Texture2D = preload(
	"res://scenes/elements/ram_8_bit/ram_8_bit_on_off_off_off_off.png"
)
const _on_off_off_off_on: Texture2D = preload(
	"res://scenes/elements/ram_8_bit/ram_8_bit_on_off_off_off_on.png"
)
# data off write off
const _off_off_off_on_off: Texture2D = preload(
	"res://scenes/elements/ram_8_bit/ram_8_bit_off_off_off_on_off.png"
)
const _off_off_on_off_off: Texture2D = preload(
	"res://scenes/elements/ram_8_bit/ram_8_bit_off_off_on_off_off.png"
)
const _off_off_on_on_off: Texture2D = preload(
	"res://scenes/elements/ram_8_bit/ram_8_bit_off_off_on_on_off.png"
)
const _off_on_off_off_off: Texture2D = preload(
	"res://scenes/elements/ram_8_bit/ram_8_bit_off_on_off_off_off.png"
)
const _off_on_off_on_off: Texture2D = preload(
	"res://scenes/elements/ram_8_bit/ram_8_bit_off_on_off_on_off.png"
)
const _off_on_on_off_off: Texture2D = preload(
	"res://scenes/elements/ram_8_bit/ram_8_bit_off_on_on_off_off.png"
)
const _off_on_on_on_off: Texture2D = preload(
	"res://scenes/elements/ram_8_bit/ram_8_bit_off_on_on_on_off.png"
)
# data on write on
const _on_off_on_on_on: Texture2D = preload(
	"res://scenes/elements/ram_8_bit/ram_8_bit_on_off_on_on_on.png"
)
const _on_on_off_on_on: Texture2D = preload(
	"res://scenes/elements/ram_8_bit/ram_8_bit_on_on_off_on_on.png"
)
const _on_on_on_off_on: Texture2D = preload(
	"res://scenes/elements/ram_8_bit/ram_8_bit_on_on_on_off_on.png"
)
const _on_off_off_on_on: Texture2D = preload(
	"res://scenes/elements/ram_8_bit/ram_8_bit_on_off_off_on_on.png"
)
const _on_off_on_off_on: Texture2D = preload(
	"res://scenes/elements/ram_8_bit/ram_8_bit_on_off_on_off_on.png"
)
const _on_on_off_off_on: Texture2D = preload(
	"res://scenes/elements/ram_8_bit/ram_8_bit_on_on_off_off_on.png"
)
# data off write on
const _off_on_on_on_on: Texture2D = preload(
	"res://scenes/elements/ram_8_bit/ram_8_bit_off_on_on_on_on.png"
)
const _off_off_on_on_on: Texture2D = preload(
	"res://scenes/elements/ram_8_bit/ram_8_bit_off_off_on_on_on.png"
)
const _off_on_off_on_on: Texture2D = preload(
	"res://scenes/elements/ram_8_bit/ram_8_bit_off_on_off_on_on.png"
)
const _off_on_on_off_on: Texture2D = preload(
	"res://scenes/elements/ram_8_bit/ram_8_bit_off_on_on_off_on.png"
)
const _off_off_off_on_on: Texture2D = preload(
	"res://scenes/elements/ram_8_bit/ram_8_bit_off_off_off_on_on.png"
)
const _off_off_on_off_on: Texture2D = preload(
	"res://scenes/elements/ram_8_bit/ram_8_bit_off_off_on_off_on.png"
)
const _off_on_off_off_on: Texture2D = preload(
	"res://scenes/elements/ram_8_bit/ram_8_bit_off_on_off_off_on.png"
)
# data on write off
const _on_on_on_on_off: Texture2D = preload(
	"res://scenes/elements/ram_8_bit/ram_8_bit_on_on_on_on_off.png"
)
const _on_off_on_on_off: Texture2D = preload(
	"res://scenes/elements/ram_8_bit/ram_8_bit_on_off_on_on_off.png"
)
const _on_on_off_on_off: Texture2D = preload(
	"res://scenes/elements/ram_8_bit/ram_8_bit_on_on_off_on_off.png"
)
const _on_on_on_off_off: Texture2D = preload(
	"res://scenes/elements/ram_8_bit/ram_8_bit_on_on_on_off_off.png"
)
const _on_off_off_on_off: Texture2D = preload(
	"res://scenes/elements/ram_8_bit/ram_8_bit_on_off_off_on_off.png"
)
const _on_off_on_off_off: Texture2D = preload(
	"res://scenes/elements/ram_8_bit/ram_8_bit_on_off_on_off_off.png"
)
const _on_on_off_off_off: Texture2D = preload(
	"res://scenes/elements/ram_8_bit/ram_8_bit_on_on_off_off_off.png"
)

var _ram: Array = [0, 0, 0, 0, 0, 0, 0, 0]

const _relay_util_class: Resource = preload("res://utils/relay_delay_util.gd")
var _relay_util1: RelayDelayUtil = _relay_util_class.new()
var _relay_util2: RelayDelayUtil = _relay_util_class.new()
var _relay_util3: RelayDelayUtil = _relay_util_class.new()
var _relay_util4: RelayDelayUtil = _relay_util_class.new()
var _relay_util5: RelayDelayUtil = _relay_util_class.new()

func _ready() -> void:
	type = Globals.Elements.RAM_8_BIT
	add_to_group("Energy")
	super()

func reset_energy():
	_relay_util1.reset()
	_relay_util2.reset()
	_relay_util3.reset()
	_relay_util4.reset()
	_relay_util5.reset()
	_set_off_texture()
	super()

func _write(index: int, value: int):
	_ram[index] = value

func _has_energy() -> bool:
	var in1: bool = _relay_util1.run($Connectors/In.connected_has_energy())
	var in2: bool = _relay_util2.run($Connectors/In2.connected_has_energy())
	var in3: bool = _relay_util3.run($Connectors/In3.connected_has_energy())
	var in4: bool = _relay_util4.run($Connectors/In4.connected_has_energy())
	var in5: bool = _relay_util5.run($Connectors/In5.connected_has_energy())

	if in1 && in5:
		# write
		if in2 && in3 && in4:
			_ram[7] = 1
			_on_texture = self._on
		elif in2 && in3:
			_ram[3] = 1
			_on_texture = self._on_off_on_on_on
		elif in2 && in4:
			_ram[5] = 1
			_on_texture = self._on_on_off_on_on
		elif in3 && in4:
			_ram[6] = 1
			_on_texture = self._on_on_on_off_on
		elif in2:
			_ram[1] = 1
			_on_texture = self._on_off_off_on_on
		elif in3:
			_ram[2] = 1
			_on_texture = self._on_off_on_off_on
		elif in4:
			_ram[4] = 1
			_on_texture = self._on_on_off_off_on
		else:
			_ram[0] = 1
			_on_texture = self._on_off_off_off_on
		$Connectors/Out.set_energy(true)
		return true
	elif in1:
		# reset
		if in2 && in3 && in4:
			_ram[7] = 0
			_off_texture = self._off_on_on_on_on
		elif in2 && in3:
			_ram[3] = 0
			_off_texture = self._off_off_on_on_on
		elif in2 && in4:
			_ram[5] = 0
			_off_texture = self._off_on_off_on_on
		elif in3 && in4:
			_ram[6] = 0
			_off_texture = self._off_on_on_off_on
		elif in2:
			_ram[1] = 0
			_off_texture = self._off_off_off_on_on
		elif in3:
			_ram[2] = 0
			_off_texture = self._off_off_on_off_on
		elif in4:
			_ram[4] = 0
			_off_texture = self._off_on_off_off_on
		else:
			_ram[0] = 0
			_off_texture = self._off_off_off_off_on
		$Connectors/Out.set_energy(false)
		return false
	elif in5:
		# data
		if in2 && in3 && in4:
			if _ram[7]:
				_on_texture = self._on_on_on_on_off
				$Connectors/Out.set_energy(true)
				return true
			_off_texture = self._on_on_on_on_off
		elif in2 && in3:
			if _ram[3]:
				_on_texture = self._on_off_on_on_off
				$Connectors/Out.set_energy(true)
				return true
			_off_texture = self._on_off_on_on_off
		elif in2 && in4:
			if _ram[5]:
				_on_texture = self._on_on_off_on_off
				$Connectors/Out.set_energy(true)
				return true
			_off_texture = self._on_on_off_on_off
		elif in3 && in4:
			if _ram[6]:
				_on_texture = self._on_on_on_off_off
				$Connectors/Out.set_energy(true)
				return true
			_off_texture = self._on_on_on_off_off
		elif in2:
			if _ram[1]:
				_on_texture = self._on_off_off_on_off
				$Connectors/Out.set_energy(true)
				return true
			_off_texture = self._on_off_off_on_off
		elif in3:
			if _ram[2]:
				_on_texture = self._on_off_on_off_off
				$Connectors/Out.set_energy(true)
				return true
			_off_texture = self._on_off_on_off_off
		elif in4:
			if _ram[4]:
				_on_texture = self._on_on_off_off_off
				$Connectors/Out.set_energy(true)
				return true
			_off_texture = self._on_on_off_off_off
		else:
			if _ram[0]:
				_on_texture = self._on_off_off_off_off
				$Connectors/Out.set_energy(true)
				return true
			_off_texture = self._on_off_off_off_off
		$Connectors/Out.set_energy(false)
		return false
	elif in2 && in3 && in4:
		if _ram[7]:
			_on_texture = self._off_on_on_on_off
			$Connectors/Out.set_energy(true)
			return true
		$Connectors/Out.set_energy(false)
		_off_texture = self._off_on_on_on_off
		return false
	elif in2 && in3:
		if _ram[3]:
			_on_texture = self._off_off_on_on_off
			$Connectors/Out.set_energy(true)
			return true
		$Connectors/Out.set_energy(false)
		_off_texture = self._off_off_on_on_off
		return false
	elif in2 && in4:
		if _ram[5]:
			_on_texture = self._off_on_off_on_off
			$Connectors/Out.set_energy(true)
			return true
		$Connectors/Out.set_energy(false)
		_off_texture = self._off_on_off_on_off
		return false
	elif in3 && in4:
		if _ram[6]:
			_on_texture = self._off_on_on_off_off
			$Connectors/Out.set_energy(true)
			return true
		$Connectors/Out.set_energy(false)
		_off_texture = self._off_on_on_off_off
		return false
	elif in2:
		if _ram[1]:
			_on_texture = self._off_off_off_on_off
			$Connectors/Out.set_energy(true)
			return true
		$Connectors/Out.set_energy(false)
		_off_texture = self._off_off_off_on_off
		return false
	elif in3:
		if _ram[2]:
			_on_texture = self._off_off_on_off_off
			$Connectors/Out.set_energy(true)
			return true
		$Connectors/Out.set_energy(false)
		_off_texture = self._off_off_on_off_off
		return false
	elif in4:
		if _ram[4]:
			_on_texture = self._off_on_off_off_off
			$Connectors/Out.set_energy(true)
			return true
		$Connectors/Out.set_energy(false)
		_off_texture = self._off_on_off_off_off
		return false
	else:
		if _ram[0]:
			_on_texture = self._off
			$Connectors/Out.set_energy(true)
			return true
		$Connectors/Out.set_energy(false)
		_off_texture = self._off
		return false
