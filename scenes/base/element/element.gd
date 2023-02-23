class_name Element

extends Node2D

signal connector_area_entered
signal connector_mouse_entered
signal connector_mouse_exited

signal child_moved_on_top
signal delete_processed

signal safe_area_entered
signal safe_area_exited

export (Globals.Elements) var type
var type_name: String = ""
var sprite_size: Vector2 = Vector2()
var last_valid_position: Vector2 = Vector2()
var is_checked: bool = false

var _connectors_children: Array = []
# weird var for correctly clone group of elements
var _is_cloned: bool = false
var _is_first_area_mouse_entered: bool = false
var _safe_area_entered_areas: Dictionary = {}
var _temporary_wires: Array = []

var _on_texture: Texture = null
var _off_texture: Texture = null

func _ready() -> void:
	self.add_to_group("Elements")

	sprite_size = $Sprite.texture.get_size()

	$Sprite.material.set_shader_param("texture_size", sprite_size)
	$Sprite.material.set_shader_param(
		"stripe_color",  Globals.COLORS.SAFE_AREA_ALARM
	)
	$Sprite.material.set_shader_param(
		"outline_color",  Globals.COLORS.OUTLINE
	)

	_set_on_texture()
	_set_off_texture()
	_set_off()

	_connectors_children = $Connectors.get_children()
	for connector in _connectors_children:
		connector.connect(
			"connector_mouse_entered", self, "_on_Connector_mouse_entered"
		)
		connector.connect(
			"connector_mouse_exited", self, "_on_Connector_mouse_exited"
		)
		connector.connect(
			"connector_area_entered", self, "_on_Connector_area_entered"
		)

	type_name = Globals.Elements.keys()[type].capitalize()
	last_valid_position = position

	set_alpha(1.0)

func outline(value: bool) -> void:
	$Sprite.material.set_shader_param("is_outlined", value)

func set_alpha(value: float) -> void:
	$Sprite.modulate.a = value

func safe_area_alarm(value: bool) -> void:
	$Sprite.material.set_shader_param("is_striped",  value)

# movement

func is_mouse_entered() -> bool:
	return _is_first_area_mouse_entered

func move_element(pos: Vector2) -> void:
	position += pos
	move_connected_wires()
	remove_temporary_wires()

func move_connected_wires() -> void:
	for child in _connectors_children:
		var child_connected = child.connected_element
		var child_connected_area = child.connected_area
		if (
			child_connected
			&& child_connected_area
			&& child_connected.type == Globals.Elements.WIRE
		):
			child_connected.switch_connections()

func restore_connected_wires() -> void:
	for child in _connectors_children:
		var child_connected = child.connected_element
		var child_connected_area = child.connected_area
		if (
			child_connected
			&& child_connected_area
			&& child_connected.type == Globals.Elements.WIRE
		):
			child_connected.position = child_connected.last_valid_position

func move_wires_on_top() -> void:
	for child in _connectors_children:
		var child_connected = child.connected_element
		var child_connected_area = child.connected_area
		if (
			child_connected
			&& child_connected_area
			&& child_connected.type == Globals.Elements.WIRE
		):
			emit_signal("child_moved_on_top", child_connected)

# temporary wires

func add_temporary_wire(wire: Element) -> void:
	_temporary_wires.append(wire)

func remove_temporary_wires() -> void:
	for temporary_wire in _temporary_wires:
		if is_instance_valid(temporary_wire):
			temporary_wire.delete_if_more(Globals.GAME.CONNECTED_WIRE_LENGTH)

func clear_temporary_wires() -> void:
	_temporary_wires = []

# safe area

func is_safe_area_entered() -> bool:
	return !_safe_area_entered_areas.empty()

func set_safe_area_entered(area: Area2D):
	_safe_area_entered_areas[area] = area

func remove_safe_area_entered(area: Area2D):
	_safe_area_entered_areas.erase(area)

# connectors

func get_connectors_children() -> Array:
	return _connectors_children

func clear_connectors_children() -> void:
	_connectors_children = []

func get_entered_connector() -> Area2D:
	for child in _connectors_children:
		if child.is_mouse_entered_connector():
			return child
	return null

# cloned

func is_cloned() -> bool:
	return _is_cloned

func set_is_cloned(value: bool) -> void:
	_is_cloned = value

# popup

func flip() -> void:
	if type == Globals.Elements.WIRE:
		return

	scale = Vector2(scale.x * -1, 1)
	for child in _connectors_children:
		child.remove_connections_with_elements()

func unlink() -> void:
	for child in _connectors_children:
		var child_connected = child.connected_element
		var child_connected_area = child.connected_area
		if (
			child_connected
			&& child_connected_area
			&& child_connected.type == Globals.Elements.WIRE
		):
			child_connected.unlink_points(
				child_connected.is_in_first_points(child_connected_area),
				child_connected.is_in_second_points(child_connected_area)
			)
		child.remove_connections_with_elements()

func delete(is_animate: bool = true) -> void:
	if !is_animate:
		emit_signal("delete_processed", self)

	if type != Globals.Elements.WIRE:
		# delete calls in AnimationPlayer
		$Sprite.material.set_shader_param("is_dissolve", true)
		# In AnimationPlayer alpha changed and shader made a trick
		$AnimationPlayer.play("Delete")
	else:
		emit_signal("delete_processed", self)

# energy loop

func transfer_energy(instance: Element) -> void:
	is_checked = true

	# should called only once in one loop
	var self_energy = _has_energy()
	if self_energy:
		call_deferred("_set_on")

		for child in _connectors_children:
			var child_connected = child.connected_element
			var child_connected_area = child.connected_area
			if (
				(
					child.type == Globals.Connectors.OUT
					|| type == Globals.Elements.WIRE
				)
				&& child_connected
				&& child_connected_area
				&& child_connected != instance
			):
				# transfer only if child has energy
				if !child_connected.is_checked && child.get_energy():
					child_connected.transfer_energy(self)
	else:
		call_deferred("_set_off")

func reset_energy() -> void:
	for child in _connectors_children:
		child.set_energy(false)
	_set_off()

func _has_energy() -> bool:
	# should called only once in one loop
	push_error("Not Implemented method")
	return false

func _set_on_texture():
	_on_texture = self._on

func _set_off_texture():
	_off_texture = self._off

func _set_on():
	$Sprite.texture =_on_texture

func _set_off():
	$Sprite.texture =_off_texture

func _on_FirstArea_mouse_entered() -> void:
	_is_first_area_mouse_entered = true

func _on_FirstArea_mouse_exited() -> void:
	_is_first_area_mouse_entered = false

func _on_SafeArea_area_entered(area: Area2D) -> void:
	emit_signal("safe_area_entered", self, area, true)

func _on_SafeArea_area_exited(area: Area2D) -> void:
	emit_signal("safe_area_exited", self, area, false)

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "Delete":
		emit_signal("delete_processed", self)

func _on_Connector_mouse_entered(connector) -> void:
	emit_signal("connector_mouse_entered", self, connector)

func _on_Connector_mouse_exited() -> void:
	emit_signal("connector_mouse_exited")

func _on_Connector_area_entered(connector, other) -> void:
	emit_signal("connector_area_entered", connector, other)
