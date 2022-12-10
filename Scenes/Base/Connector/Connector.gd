extends Area2D

class_name Connector

export (Globals.Connectors) var type

var _connected: Element = null
var _connected_area: Connector = null

var _energy = false
var _on_mouse_entered: bool = false

var objects_selected_elements_size: int = 0
var objects_has_dragged_elements: bool = false

signal connector_mouse_entered
signal connector_mouse_exited
signal connector_wire_added
signal connector_area_received

func _ready() -> void:
	self.set_collision_layer_bit(0, false)
	self.set_collision_mask_bit(0, false)

func get_energy() -> bool:
	return self._energy

func set_energy(value: bool):
	self._energy = value

func get_connected() -> Element:
	return self._connected

func set_connected(element: Element) -> void:
	self._connected = element

func get_connected_area() -> Connector:
	return self._connected_area

func set_connected_area(area: Connector) -> void:
	self._connected_area = area

func reset_connection():
	self._connected = null
	self._connected_area = null

func has_connection() -> bool:
	return self._connected && self._connected_area

func connected_has_energy() -> bool:
	return self._connected_area && self._connected_area.get_energy()

static func setup_connection(
	self_: Connector,
	self_element: Element,
	other: Connector,
	other_element: Element
) -> void:
	self_.set_connected(other_element)
	self_.set_connected_area(other)
	other.set_connected(self_element)
	other.set_connected_area(self_)

# for flip and unlink
func remove_connections_with_elements() -> void:
	var self_connected_area = self.get_connected_area()
	if self_connected_area:
		self.reset_connection()
		self_connected_area.reset_connection()

# for delete
func remove_connections_with_self() -> void:
	var self_connected = self.get_connected()
	var self_connected_area = self.get_connected_area()
	if self_connected && self_connected_area:
		for connected_child in self_connected.get_connectors_children():
			if connected_child.get_connected_area() == self:
				connected_child.set_connected_area(null)
			if connected_child.get_connected() == self.owner:
				connected_child.set_connected_area(null)
	self.reset_connection()

func _on_Connector_area_entered(other: Connector) -> void:
	# use collision Layer Connector [3] and collide only with Mask In [2]

	if (
		other.owner == self.owner
		|| self.has_connection()
		|| other.has_connection()
	):
		return

	if self.owner.is_cloned() != other.owner.is_cloned():
		# to correctly reconect wires after cloning
		return

	self.emit_signal("connector_area_received", self)
	if (
		self.owner.type == Globals.Elements.WIRE
		&& other.owner.type == Globals.Elements.WIRE
	):
		if self.objects_has_dragged_elements:
			return

		if !self.owner.can_connect_to_wire(self, other):
			return

		self.setup_connection(self, self.owner, other, other.owner)
	elif (
		(
			self.owner.type == Globals.Elements.WIRE
			|| other.owner.type == Globals.Elements.WIRE
		)
	):
		if self.objects_has_dragged_elements:
			return

		if self.owner.type == Globals.Elements.WIRE:
			if !self.owner.check_connect_to_object():
				return

		if other.owner.type == Globals.Elements.WIRE:
			if !other.owner.check_connect_to_object():
				return

		self.setup_connection(self, self.owner, other, other.owner)
	else:
		# auto connection
		if (
			self.owner.type != Globals.Elements.WIRE
			&& other.owner.type != Globals.Elements.WIRE
			&& self.objects_selected_elements_size == 1
		):
			self.emit_signal("connector_wire_added", self, other)

func _on_Connector_area_exited(other: Connector) -> void:
	# use collision Layer Connector [3] and collide only with Mask In [2]

	if (
		other.owner == self.get_connected()
		&& self.has_connection()
		&& other.has_connection()
	):
		self.reset_connection()
		other.reset_connection()

func is_mouse_entered():
	return self._on_mouse_entered

func _on_Connector_mouse_entered() -> void:
	self._on_mouse_entered = true
	self.emit_signal("connector_mouse_entered", self)

func _on_Connector_mouse_exited() -> void:
	self._on_mouse_entered = false
	self.emit_signal("connector_mouse_exited")


