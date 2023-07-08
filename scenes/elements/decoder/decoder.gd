extends Element

const _on: Texture2D = preload("res://scenes/elements/decoder/decoder_on.png")
const _off: Texture2D = preload("res://scenes/elements/decoder/decoder_off.png")

const _relay_util_class: RefCounted = preload("res://utils/relay_delay_util.gd")
var _relay_util1: RelayDelayUtil = _relay_util_class.new()
var _relay_util2: RelayDelayUtil = _relay_util_class.new()

func _ready() -> void:
	type = Globals.Elements.DECODER
	super()

func reset_energy() -> void:
	_relay_util1.reset()
	_relay_util2.reset()
	_set_off_texture()
	super()

func _has_energy() -> bool:
	var in1: bool = _relay_util1.run($Connectors/In.connected_has_energy())
	var in2: bool = _relay_util2.run($Connectors/In2.connected_has_energy())

	if in1 && in2:
		$Connectors/Out.set_energy(true)
		$Connectors/Out2.set_energy(false)
		_on_texture = self._on
		return true
	elif in1:
		$Connectors/Out.set_energy(false)
		$Connectors/Out2.set_energy(false)
		_off_texture = self._on
		return false
	elif in2:
		$Connectors/Out.set_energy(false)
		$Connectors/Out2.set_energy(true)
		_on_texture = self._off
		return true
	else:
		_off_texture = self._off
		return false
