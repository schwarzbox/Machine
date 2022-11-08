extends Node2D

class_name Element

export (Globals.ELEMENTS) var type
var _type_name: String = ""

onready var sprite_size: Vector2 = $Sprite.texture.get_size()

var _connectors_children: Array = []
var _on_texture: Texture = null
var _off_texture: Texture = null

var _first_area_mouse_entered: bool = false

var _is_objects_scene_selected: bool = false
var _is_objects_has_dragged_elements: bool = false
var _is_objects_is_selecting: bool = false
var _dragged: bool = false
# weird var for correctly clone group of elements
var _cloned: bool = false

var _temporary_wires: Array = []

var checked: bool = false

signal connector_mouse_entered
signal connector_mouse_exited
signal connector_wire_added
signal connector_area_entered_received
signal delete_processed

signal element_mouse_entered_received
signal objects_is_selecting_received
signal child_moved_to_position
signal selected_elements_added
signal selected_elements_moved
signal temporary_wires_cleared
signal elements_sorted

func _ready() -> void:
	self.add_to_group("Elements")

	$Sprite.material.set_shader_param("outline_color",  Globals.COLORS.HIGHLIGHT)

	self._set_on_texture()
	self._set_off_texture()
	self._set_off()

	self._connectors_children = $Connectors.get_children()
	self.__connect_connectors_signals()

	self._type_name = Globals.ELEMENTS.keys()[self.type].capitalize()

func get_type_name() -> String:
	return self._type_name

func outline(value: bool) -> void:
	$Sprite.material.set_shader_param("is_outlined", value)

# connectors

func get_connectors_children() -> Array:
	return self._connectors_children

func is_connector_entered() -> bool:
	for child in self._connectors_children:
		if child.is_mouse_entered():
			return true
	return false

func __connect_connectors_signals() -> void:
	for connector in self._connectors_children:
		connector.connect("connector_mouse_entered", self, "_on_Connector_mouse_entered")
		connector.connect("connector_mouse_exited", self, "_on_Connector_mouse_exited")
		connector.connect("connector_wire_added", self, "_on_Connector_wire_added")
		connector.connect("connector_area_entered_received", self, "_on_Connector_connector_area_entered")

func _on_Connector_mouse_entered(has_connection: bool) -> void:
	self.emit_signal("connector_mouse_entered", self, has_connection)

func _on_Connector_mouse_exited() -> void:
	self.emit_signal("connector_mouse_exited")

func _on_Connector_wire_added(connector, other) -> void:
	self.emit_signal("connector_wire_added", connector, other)

func _on_Connector_connector_area_entered(connector) -> void:
	self.emit_signal("connector_area_entered_received", connector)

# energy loop

func _set_on_texture():
	self._on_texture = self._on

func _set_off_texture():
	self._off_texture = self._off

func _set_on():
	$Sprite.texture = self._on_texture

func _set_off():
	$Sprite.texture = self._off_texture

func reset_energy() -> void:
	for child in self._connectors_children:
		child.set_energy(false)
	self._set_off()

func __has_energy() -> bool:
	# should called only once in one loop
	push_error("Not Implemented method")
	return false

func transfer_energy(instance: Element) -> void:
	self.checked = true

	# should called only once in one loop
	var self_energy = self.__has_energy()
	if self_energy:
		self.call_deferred("_set_on")

		for child in self._connectors_children:
			var child_connected = child.get_connected()
			var child_connected_area = child.get_connected_area()
			if (
				(
					child.type == Globals.CONNECTORS.OUT
					|| self.type == Globals.ELEMENTS.WIRE
				)
				&& child_connected
				&& child_connected_area
				&& child_connected != instance
			):
				# transfer only if child has energy
				if not child_connected.checked and child.get_energy():
					child_connected.transfer_energy(self)
	else:
		self.call_deferred("_set_off")

# management

func flip() -> void:
	if self.type == Globals.ELEMENTS.WIRE:
		return

	self.scale = Vector2(self.scale.x * -1, 1)
	for child in self._connectors_children:
		child.remove_connections_with_elements()

func unlink() -> void:
	for child in self._connectors_children:
		var child_connected = child.get_connected()
		var child_connected_area = child.get_connected_area()
		if (
			child_connected
			and child_connected_area
			and child_connected.type == Globals.ELEMENTS.WIRE
		):
			child_connected.unlink_points(
				child_connected.is_in_first_points(child_connected_area),
				child_connected.is_in_second_points(child_connected_area)
			)
		child.remove_connections_with_elements()

func delete(is_animate: bool = true) -> void:
	if not is_animate:
		self.emit_signal("delete_processed", self)

	if self.type != Globals.ELEMENTS.WIRE:
		# delete calls in AnimationPlayer
		$Sprite.material.set_shader_param("is_dissolve", true)
		# In AnimationPlayer alpha changed and shader made a trick
		$AnimationPlayer.play("Delete")
	else:
		self.emit_signal("delete_processed", self)

func add_temporary_wire(wire: Element) -> void:
	self._temporary_wires.append(wire)

func remove_temporary_wires() -> void:
	for temporary_wire in self._temporary_wires:
		if is_instance_valid(temporary_wire):
			temporary_wire.delete_if_more(Globals.GAME.CONNECTED_WIRE_LENGTH)

func clear_temporary_wires() -> void:
	self._temporary_wires = []

func is_mouse_entered() -> bool:
	return self._first_area_mouse_entered

func is_dragged() -> bool:
	return self._dragged

func is_cloned() -> bool:
	return self._cloned

func set_cloned(value: bool) -> void:
	self._cloned = value

func _move_connected_wires() -> void:
	for child in self._connectors_children:
		var child_connected = child.get_connected()
		var child_connected_area = child.get_connected_area()
		if (
			child_connected
			and child_connected_area
			and child_connected.type == Globals.ELEMENTS.WIRE
		):
			child_connected.switch_connections()


func move_wires_to_position(pos = null) -> void:
	for child in self._connectors_children:
		var child_connected = child.get_connected()
		var child_connected_area = child.get_connected_area()
		if (
			child_connected
			and child_connected_area
			and child_connected.type == Globals.ELEMENTS.WIRE
		):
			self.emit_signal("child_moved_to_position", child_connected, pos)

func _drag_and_drop(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			# sort before move on top selected
			self.emit_signal("elements_sorted")
			# move on top when pressed
			self.emit_signal("child_moved_to_position", self)
			self.move_wires_to_position()

			self.emit_signal("selected_elements_added", self)

			self.get_tree().set_input_as_handled()
		else:
			self.emit_signal("temporary_wires_cleared", self)
			self._dragged = false

	self.emit_signal("objects_is_selecting_received", self)
	if event is InputEventScreenDrag && not self._is_objects_is_selecting:
		self.emit_signal("selected_elements_moved", event)

		self._move_connected_wires()
		self.remove_temporary_wires()
		self._dragged = true

		self.get_tree().set_input_as_handled()

func _unhandled_input(event: InputEvent) -> void:
	if self.is_mouse_entered():

		self.emit_signal("element_mouse_entered_received", self)
		if self._is_objects_scene_selected:
			return

		if not self._is_objects_has_dragged_elements || self._dragged:
			self._drag_and_drop(event)

func _on_FirstArea_mouse_entered() -> void:
	self._first_area_mouse_entered = true

func _on_FirstArea_mouse_exited() -> void:
	self._first_area_mouse_entered = false

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "Delete":
		self.emit_signal("delete_processed", self)

#func _outline_connected() -> void:
#	var entered_element = self.objects.get_mouse_entered_element()
#	if entered_element:
#		entered_element.call_deferred("outline", true)


