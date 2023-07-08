extends Element

const _on: Texture2D = preload("res://scenes/elements/trigger_front/trigger_front_on.png")
const _off: Texture2D = preload("res://scenes/elements/trigger_front/trigger_front_off.png")

const _relay_util_class: RefCounted = preload("res://utils/relay_delay_util.gd")
var _relay_util1: RelayDelayUtil = _relay_util_class.new()
var _relay_util2: RelayDelayUtil = _relay_util_class.new()
var _relay_util3: RelayDelayUtil = _relay_util_class.new()

var _last_out_connector: NodePath = ^""
var _last_texture: Texture2D = null
var _last_state: bool = false

func _ready() -> void:
	type = Globals.Elements.EDGE_FLIP_FLOP
	add_to_group("Energy")
	super()

func reset_energy():
	_relay_util1.reset()
	_relay_util2.reset()
	_relay_util3.reset()
	_set_off_texture()
	super()

func _reset_memory():
	$Connectors/Out.set_energy(false)
	$Connectors/Out2.set_energy(false)
	_last_out_connector = ^""
	_last_texture = null
	_last_state = false

func _has_energy() -> bool:
	var in1: bool = _relay_util1.run($Connectors/In.connected_has_energy())
	var in2: bool = _relay_util2.run($Connectors/In2.connected_has_energy())
	var in3: bool = _relay_util3.run($Connectors/In3.connected_has_energy())

	if in1 && in2 && in3:
		_reset_memory()
		_off_texture = self._off
		return false
	if in1 && in2:
		_reset_memory()
		_off_texture = self._off
		return false
	if in2 && in3:
		_reset_memory()
		_off_texture = self._off
		return false
	elif in1 && in3:
		if !_last_state:
			_last_out_connector = ^"Connectors/Out"
			_last_texture = self._on
			_last_state = true
			$Connectors/Out.set_energy(true)
			$Connectors/Out2.set_energy(false)
			_on_texture = self._on
		else:
			if _last_out_connector == ^"Connectors/Out":
				_on_texture = self._on
			else:
				_on_texture = self._off
		return true
	elif in1:
		if !_last_state:
			_last_out_connector = ^"Connectors/Out2"
			_last_texture = self._off
			_last_state = true
			$Connectors/Out.set_energy(false)
			$Connectors/Out2.set_energy(true)
			_on_texture = self._off
		else:
			if _last_out_connector == ^"Connectors/Out2":
				_on_texture = self._off
			else:
				_on_texture = self._on
		return true
	elif in2:
		_reset_memory()
		_off_texture = self._off
		return false
	elif in3:
		_last_state = false
		if _last_out_connector == ^"Connectors/Out":
			_on_texture = self._on
		else:
			_on_texture = self._off
		return true
	else:
		_last_state = false
		if _last_out_connector:
			get_node(_last_out_connector).set_energy(true)
			_on_texture = _last_texture
		else:
			$Connectors/Out.set_energy(false)
			$Connectors/Out2.set_energy(true)
			_on_texture = self._off
		return true

