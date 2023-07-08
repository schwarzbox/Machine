extends Element

const _on: Texture2D = preload("res://scenes/elements/full_adder/full_adder_on.png")
const _off: Texture2D = preload("res://scenes/elements/full_adder/full_adder_off.png")
const _on_off_off: Texture2D = preload("res://scenes/elements/full_adder/full_adder_on_off_off.png")
const _on_on_off: Texture2D = preload("res://scenes/elements/full_adder/full_adder_on_on_off.png")

const _relay_util_class: RefCounted = preload("res://utils/relay_delay_util.gd")
var _relay_util1: RelayDelayUtil = _relay_util_class.new()
var _relay_util2: RelayDelayUtil = _relay_util_class.new()
var _relay_util3: RelayDelayUtil = _relay_util_class.new()

func _ready() -> void:
	type = Globals.Elements.FULL_ADDER

	super()

func reset_energy() -> void:
	_relay_util1.reset()
	_relay_util2.reset()
	_relay_util3.reset()
	_set_off_texture()
	super()

func _has_energy() -> bool:
	var in1: bool = _relay_util1.run($Connectors/In.connected_has_energy())
	var in2: bool = _relay_util2.run($Connectors/In2.connected_has_energy())
	var in3: bool = _relay_util3.run($Connectors/In3.connected_has_energy())

	if in1 && in2 && in3:
		$Connectors/Out.set_energy(true)
		$Connectors/Out2.set_energy(true)
		_on_texture = self._on
		return true
	elif in1 && in2:
		$Connectors/Out.set_energy(false)
		$Connectors/Out2.set_energy(true)
		_on_texture = self._on_on_off
		return true
	elif in2 && in3:
		$Connectors/Out.set_energy(false)
		$Connectors/Out2.set_energy(true)
		_on_texture = self._on_on_off
		return true
	elif in1 && in3:
		$Connectors/Out.set_energy(false)
		$Connectors/Out2.set_energy(true)
		_on_texture = self._on_on_off
		return true
	elif in1:
		$Connectors/Out.set_energy(true)
		$Connectors/Out2.set_energy(false)
		_on_texture = self._on_off_off
		return true
	elif in2:
		$Connectors/Out.set_energy(true)
		$Connectors/Out2.set_energy(false)
		_on_texture = self._on_off_off
		return true
	elif in3:
		$Connectors/Out.set_energy(true)
		$Connectors/Out2.set_energy(false)
		_on_texture = self._on_off_off
		return true
	else:
		_off_texture = self._off
		return false
