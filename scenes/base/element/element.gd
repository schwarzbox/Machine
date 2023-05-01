class_name Element

extends Node2D

signal connector_area_entered
signal connector_area_exited
signal connector_mouse_entered
signal connector_mouse_exited

signal child_moved_on_top
signal delete_processed

signal safe_area_entered
signal safe_area_exited

@export var type: Globals.Elements

var type_name: String = ""
var sprite_size: Vector2 = Vector2()
var half_sprite_size: Vector2 = Vector2()
var is_checked: bool = false

# var for correctly clone group of elements
var _is_cloned: bool = false: get = is_cloned, set =  set_is_cloned
var _is_first_area_mouse_entered: bool = false
var _safe_area_entered_areas: Dictionary = {}
var _temporary_wires: Array = []:
	set(_value): return

var _on_texture: Texture2D = null
var _off_texture: Texture2D = null

@onready var last_valid_position: Vector2 = position
@onready var connectors_children: Array = $Connectors.get_children():
	set(_value): return

func _ready() -> void:
	add_to_group("Elements")

	# prevent any error with type_name setup
	(func():
		type_name = Globals.Elements.keys()[type].capitalize()
	).call_deferred()

	sprite_size = $FirstSprite2D.texture.get_size()
	half_sprite_size = sprite_size / 2

	$FirstSprite2D.material.set_shader_parameter("texture_size", sprite_size)
	$FirstSprite2D.material.set_shader_parameter(
		"stripe_color",  Globals.COLORS.SAFE_AREA_ALARM
	)
	$FirstSprite2D.material.set_shader_parameter(
		"outline_color",  Globals.COLORS.OUTLINE
	)

	_set_on_texture()
	_set_off_texture()
	_set_off()

	for connector in connectors_children:
		connector.connect(
			"connector_mouse_entered", self._on_connector_mouse_entered
		)
		connector.connect(
			"connector_mouse_exited", self._on_connector_mouse_exited
		)
		connector.connect(
			"connector_area_entered", self._on_connector_area_entered
		)
		connector.connect(
			"connector_area_exited", self._on_connector_area_exited
		)

	$VisibleOnScreenNotifier2D.rect.position = half_sprite_size * -1
	$VisibleOnScreenNotifier2D.rect.size = sprite_size

	# hide all invisible elements
	visible_hide()

func outline(value: bool) -> void:
	$FirstSprite2D.material.set_shader_parameter("is_outlined", value)

func visible_show() -> void:
	$FirstArea.show()
	$FirstSprite2D.show()
	$SafeArea.show()
	$Connectors.show()

func visible_hide() -> void:
	$FirstArea.hide()
	$FirstSprite2D.hide()
	$SafeArea.hide()
	$Connectors.hide()

func safe_area_alarm(value: bool) -> void:
	$FirstSprite2D.material.set_shader_parameter("is_striped",  value)

# movement

func is_mouse_entered() -> bool:
	return _is_first_area_mouse_entered

func is_mouse_intersect_with_shape(mouse_pos: Vector2) -> bool:
	return $FirstSprite2D.get_rect().has_point($FirstSprite2D.to_local(mouse_pos))

func move_element(pos: Vector2) -> void:
	position += pos
	move_connected_wires()
	remove_temporary_wires()

func move_connected_wires() -> void:
	for child in connectors_children:
		var child_connected = child.connected_element
		var child_connected_area = child.connected_area
		if (
			child_connected
			&& child_connected_area
			&& child_connected.type == Globals.Elements.WIRE
		):
			_update_connected_wire(child_connected)

func restore_connected_wires() -> void:
	for child in connectors_children:
		var child_connected = child.connected_element
		var child_connected_area = child.connected_area
		if (
			child_connected
			&& child_connected_area
			&& child_connected.type == Globals.Elements.WIRE
		):
			child_connected.position = child_connected.last_valid_position

func move_wires_on_top() -> void:
	for child in connectors_children:
		var child_connected = child.connected_element
		var child_connected_area = child.connected_area
		if (
			child_connected
			&& child_connected_area
			&& child_connected.type == Globals.Elements.WIRE
		):
			emit_signal("child_moved_on_top", child_connected)

func check_connect_to_wire(
	connector: Connector, with_connection: bool = true
) -> bool:
	if connector.has_connection():
		return false
	return true

# temporary wires

func add_temporary_wire(wire: Element) -> void:
	_temporary_wires.append(wire)

func remove_temporary_wires() -> void:
	for temporary_wire in _temporary_wires:
		if is_instance_valid(temporary_wire):
			temporary_wire.delete_if_more(Globals.GAME.CONNECTED_WIRE_LENGTH)

func clear_temporary_wires() -> void:
	_temporary_wires.clear()

# safe area

func is_safe_area_entered() -> bool:
	return !_safe_area_entered_areas.is_empty()

func set_safe_area_entered(area: Area2D):
	_safe_area_entered_areas[area] = area

func remove_safe_area_entered(area: Area2D):
	_safe_area_entered_areas.erase(area)

# connectors

func get_connectors_children() -> Array:
	return connectors_children

func clear_connectors_children() -> void:
	connectors_children.clear()

func get_entered_connector() -> Connector:
	for child in connectors_children:
		if child.is_mouse_entered_connector():
			return child
	return null

# cloned

func is_cloned() -> bool:
	return _is_cloned

func set_is_cloned(value: bool) -> void:
	_is_cloned = value

# popup

func rotate_cw() -> void:
	if type == Globals.Elements.WIRE:
		return

	self.rotation += PI / 2

	for child in connectors_children:
		child.remove_connections_with_elements()

func rotate_ccw() -> void:
	if type == Globals.Elements.WIRE:
		return

	self.rotation -= PI / 2

	for child in connectors_children:
		child.remove_connections_with_elements()

func unlink() -> void:
	for child in connectors_children:
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
		# set is_dissolve in AnimationPlayer
		# in AnimationPlayer texture_alpha changed and shader made a trick
		# delete calls with signal when animation finished
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

		for child in connectors_children:
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
	for child in connectors_children:
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
	$FirstSprite2D.texture =_on_texture

func _set_off():
	$FirstSprite2D.texture =_off_texture

func _update_connected_wire(element: Element) -> void:
	element.sync_wire_nodes()

func _on_first_area_mouse_entered() -> void:
	_is_first_area_mouse_entered = true

func _on_first_area_mouse_exited() -> void:
	_is_first_area_mouse_entered = false

func _on_safe_area_area_entered(area: Area2D) -> void:
	emit_signal("safe_area_entered", self, area, true)

func _on_safe_area_area_exited(area: Area2D) -> void:
	emit_signal("safe_area_exited", self, area, false)

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	visible_show()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	visible_hide()

func _on_animation_player_animation_finished(anim_name: String) -> void:
	if anim_name == "Delete":
		emit_signal("delete_processed", self)

func _on_connector_mouse_entered(connector) -> void:
	emit_signal("connector_mouse_entered", self, connector)

func _on_connector_mouse_exited() -> void:
	emit_signal("connector_mouse_exited")

func _on_connector_area_entered(connector: Connector, other: Connector) -> void:
	emit_signal("connector_area_entered", connector, other)

func _on_connector_area_exited(connector: Connector, other: Connector) -> void:
	emit_signal("connector_area_exited", connector, other)
