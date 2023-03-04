extends Element

const _on: Texture2D = preload("res://scenes/elements/ex_or/ex_or_on.png")
const _off: Texture2D = preload("res://scenes/elements/ex_or/ex_or_off.png")
const _on_off: Texture2D = preload("res://scenes/elements/ex_or/ex_or_on_off.png")
const _off_on: Texture2D = preload("res://scenes/elements/ex_or/ex_or_off_on.png")

const _relay_util_class: Resource = preload("res://utils/relay_delay_util.gd")
var _relay_util1: RelayDelayUtil = _relay_util_class.new()
var _relay_util2: RelayDelayUtil = _relay_util_class.new()

func _ready() -> void:
	type = Globals.Elements.EX_OR

	super._ready()

func reset_energy():
	_relay_util1.reset()
	_relay_util2.reset()
	_set_off_texture()
	super.reset_energy()

func _has_energy() -> bool:
	var in1 = _relay_util1.run($Connectors/In.connected_has_energy())
	var in2 = _relay_util2.run($Connectors/In2.connected_has_energy())

	if in1 && in2:
		_off_texture = self._on
		return false
	elif in1:
		$Connectors/Out.set_energy(true)
		_on_texture = self._off_on
		return true
	elif in2:
		$Connectors/Out.set_energy(true)
		_on_texture = self._on_off
		return true
	else:
		_off_texture = self._off
		return false
