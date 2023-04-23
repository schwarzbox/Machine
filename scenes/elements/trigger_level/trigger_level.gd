extends Element

const _on: Texture2D = preload("res://scenes/elements/trigger_level/trigger_level_on.png")
const _off: Texture2D = preload("res://scenes/elements/trigger_level/trigger_level_off.png")
const _on_off: Texture2D = preload("res://scenes/elements/trigger_level/trigger_level_on_off.png")
const _off_on: Texture2D = preload("res://scenes/elements/trigger_level/trigger_level_off_on.png")
const _on_off_out_mem: Texture2D = preload("res://scenes/elements/trigger_level/trigger_level_on_off_out_mem.png")

const _in_mem: Texture2D = preload("res://scenes/elements/trigger_level/trigger_level_in_mem.png")
const _out_mem: Texture2D = _off

const _relay_util_class: Resource = preload("res://utils/relay_delay_util.gd")
var _relay_util1: RelayDelayUtil = _relay_util_class.new()
var _relay_util2: RelayDelayUtil = _relay_util_class.new()

var _last_out_connector: String = ""
var _last_texture: Texture2D = null

func _ready() -> void:
	type = Globals.Elements.TRIGGER_LEVEL
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
		_last_out_connector = "Connectors/Out"
		_last_texture = self._in_mem
		$Connectors/Out.set_energy(true)
		$Connectors/Out2.set_energy(false)
		_on_texture = self._on
		return true
	elif in1:
		_last_out_connector = "Connectors/Out2"
		_last_texture = self._out_mem
		$Connectors/Out.set_energy(false)
		$Connectors/Out2.set_energy(true)
		_on_texture = self._off_on
		return true
	elif in2:
		if _last_out_connector == "Connectors/Out":
			_on_texture = self._on_off
			return true
		else:
			_on_texture = self._on_off_out_mem
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

