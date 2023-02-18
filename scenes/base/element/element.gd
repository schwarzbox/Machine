class_name Element

extends Node2D

signal connector_mouse_entered
signal connector_mouse_exited
signal connector_area_entered

signal delete_processed
signal child_moved_on_top
signal safe_area_entered
signal safe_area_exited

export (Globals.Elements) var type
var _type_name: String = ""

var _connectors_children: Array = []
var _on_texture: Texture = null
var _off_texture: Texture = null

var _first_area_mouse_entered: bool = false
var _safe_areas_element_entered: Dictionary = {}

# weird var for correctly clone group of elements
var _cloned: bool = false

var _temporary_wires: Array = []

var sprite_size: Vector2 = Vector2()
var last_valid_position: Vector2 = Vector2()
var checked: bool = false

func _ready() -> void:
	self.add_to_group("Elements")

	self.sprite_size = $Sprite.texture.get_size()

	$Sprite.material.set_shader_param("texture_size",  self.sprite_size)
	$Sprite.material.set_shader_param(
		"stripe_color",  Globals.COLORS.SAFE_AREA_ALARM
	)
	$Sprite.material.set_shader_param(
		"outline_color",  Globals.COLORS.OUTLINE
	)

	self._set_on_texture()
	self._set_off_texture()
	self._set_off()

	self._connectors_children = $Connectors.get_children()
	self.__connect_connectors_signals()

	self._type_name = Globals.Elements.keys()[self.type].capitalize()
	self.last_valid_position = self.position

	self.set_alpha(1.0)

func get_type_name() -> String:
	return self._type_name

func safe_area_alarm(value: bool) -> void:
	$Sprite.material.set_shader_param("is_striped",  value)

func outline(value: bool) -> void:
	$Sprite.material.set_shader_param("is_outlined", value)

func set_alpha(value) -> void:
	$Sprite.modulate.a = value

# connectors

func get_connectors_children() -> Array:
	return self._connectors_children

func get_entered_connector() -> Area2D:
	for child in self._connectors_children:
		if child.is_mouse_entered():
			return child
	return null

func __connect_connectors_signals() -> void:
	for connector in self._connectors_children:
		connector.connect("connector_mouse_entered", self, "_on_Connector_mouse_entered")
		connector.connect("connector_mouse_exited", self, "_on_Connector_mouse_exited")
		connector.connect("connector_area_entered", self, "_on_Connector_area_entered")

func _on_Connector_mouse_entered(connector) -> void:
	self.emit_signal("connector_mouse_entered", self, connector)

func _on_Connector_mouse_exited() -> void:
	self.emit_signal("connector_mouse_exited")

func _on_Connector_area_entered(connector, other) -> void:
	self.emit_signal("connector_area_entered", connector, other)

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
					child.type == Globals.Connectors.OUT
					|| self.type == Globals.Elements.WIRE
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
	if self.type == Globals.Elements.WIRE:
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
			and child_connected.type == Globals.Elements.WIRE
		):
			child_connected.unlink_points(
				child_connected.is_in_first_points(child_connected_area),
				child_connected.is_in_second_points(child_connected_area)
			)
		child.remove_connections_with_elements()

func delete(is_animate: bool = true) -> void:
	if not is_animate:
		self.emit_signal("delete_processed", self)

	if self.type != Globals.Elements.WIRE:
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

func is_safe_area_entered() -> bool:
	return not self._safe_areas_element_entered.empty()

func is_cloned() -> bool:
	return self._cloned

func set_cloned(value: bool) -> void:
	self._cloned = value

func move_connected_wires() -> void:
	for child in self._connectors_children:
		var child_connected = child.get_connected()
		var child_connected_area = child.get_connected_area()
		if (
			child_connected
			and child_connected_area
			and child_connected.type == Globals.Elements.WIRE
		):
			child_connected.switch_connections()

func restore_connected_wires() -> void:
	for child in self._connectors_children:
		var child_connected = child.get_connected()
		var child_connected_area = child.get_connected_area()
		if (
			child_connected
			and child_connected_area
			and child_connected.type == Globals.Elements.WIRE
		):
			child_connected.position = child_connected.last_valid_position

func move_wires_on_top() -> void:
	for child in _connectors_children:
		var child_connected = child.get_connected()
		var child_connected_area = child.get_connected_area()
		if (
			child_connected
			and child_connected_area
			and child_connected.type == Globals.Elements.WIRE
		):
			emit_signal("child_moved_on_top", child_connected)

func move_element(pos: Vector2) -> void:
	self.position += pos
	move_connected_wires()
	remove_temporary_wires()

func _on_FirstArea_mouse_entered() -> void:
	self._first_area_mouse_entered = true

func _on_FirstArea_mouse_exited() -> void:
	self._first_area_mouse_entered = false

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "Delete":
		self.emit_signal("delete_processed", self)

func _on_SafeArea_area_entered(area: Area2D) -> void:
	self.emit_signal("safe_area_entered", self, area, true)

func _on_SafeArea_area_exited(area: Area2D) -> void:
	self.emit_signal("safe_area_exited", self, area, false)

