class_name Connector

extends Area2D

signal connector_mouse_entered
signal connector_mouse_exited
signal connector_area_entered

@export var type: Globals.Connectors

var connected_element: Element = null
var connected_area: Connector = null

var _is_mouse_entered: bool = false

var _energy: bool = false

func _ready() -> void:
	set_collision_layer_value(0, false)
	set_collision_mask_value(0, false)

func get_energy() -> bool:
	return _energy

func set_energy(value: bool) -> void:
	_energy = value

func has_connection() -> bool:
	return connected_element && connected_area

func connected_has_energy() -> bool:
	return connected_area && connected_area.get_energy()

func is_mouse_entered_connector() -> bool:
	return _is_mouse_entered

# for flip and unlink
func remove_connections_with_elements() -> void:
	var self_connected_area: Connector = connected_area
	if self_connected_area:
		_reset_connection()
		self_connected_area._reset_connection()

# for delete
func remove_connections_with_self() -> void:
	var self_connected: Element = connected_element
	var self_connected_area: Connector = connected_area
	if self_connected && self_connected_area:
		for connected_child in self_connected.get_connectors_children():
			if connected_child.connected_area == self:
				connected_child.connected_area = null
			if connected_child.connected_element == owner:
				connected_child.connected_area = null
	_reset_connection()

func _reset_connection() -> void:
	connected_element = null
	connected_area = null

func _on_area_entered(other: Connector) -> void:
	# use collision Layer Out [3] and collide only with Mask In [2]
	if (
		other.owner == owner
		|| has_connection()
		|| other.has_connection()
	):
		return

	if owner.is_cloned() != other.owner.is_cloned():
		# to correctly reconect wires after cloning
		return

	emit_signal("connector_area_entered", self, other)

func _on_area_exited(other: Connector) -> void:
	# use collision Layer Out [3] and collide only with Mask In [2]
	if (
		other.owner == connected_element
		&& has_connection()
		&& other.has_connection()
	):
		_reset_connection()
		other._reset_connection()

func _on_mouse_entered() -> void:
	_is_mouse_entered = true
	emit_signal("connector_mouse_entered", self)

func _on_mouse_exited() -> void:
	_is_mouse_entered = false
	emit_signal("connector_mouse_exited")

static func setup_connection(
	self_connector: Connector,
	self_element: Element,
	other_connector: Connector,
	other_element: Element
) -> void:

	self_connector.connected_element = other_element
	self_connector.connected_area = other_connector
	other_connector.connected_element = self_element
	other_connector.connected_area = self_connector
