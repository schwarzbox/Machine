extends Element

const _on: Texture2D = preload("res://scenes/elements/trigger_level/trigger_level_on.png")
const _off: Texture2D = preload("res://scenes/elements/trigger_level/trigger_level_off.png")

const _relay_util_class: RefCounted = preload("res://utils/relay_delay_util.gd")
var _relay_util1: RelayDelayUtil = _relay_util_class.new()
var _relay_util2: RelayDelayUtil = _relay_util_class.new()

var _last_out_connector: NodePath = ^""
var _last_texture: Texture2D = null

func _ready() -> void:
	type = Globals.Elements.LEVEL_FLIP_FLOP
	add_to_group("Energy")
	super()

func reset_energy():
	_relay_util1.reset()
	_relay_util2.reset()
	_set_off_texture()
	super()

func _has_energy() -> bool:
	var in1: bool = _relay_util1.run($Connectors/In.connected_has_energy())
	var in2: bool = _relay_util2.run($Connectors/In2.connected_has_energy())

	if in1 && in2:
		_last_out_connector = ^"Connectors/Out"
		_last_texture = self._on
		$Connectors/Out.set_energy(true)
		$Connectors/Out2.set_energy(false)
		_on_texture = self._on
		return true
	elif in1:
		_last_out_connector = ^""
		_last_texture = self._off
		$Connectors/Out.set_energy(false)
		$Connectors/Out2.set_energy(true)
		_on_texture = self._off
		return true
	elif in2:
		if _last_out_connector == ^"Connectors/Out":
			_on_texture = self._on
			return true
		else:
			_on_texture = self._off
			return true
	else:
		if _last_out_connector:
			get_node(_last_out_connector).set_energy(true)
			_on_texture = _last_texture
			return true
		else:
			$Connectors/Out.set_energy(false)
			$Connectors/Out2.set_energy(true)
			_on_texture = self._off
			return true

