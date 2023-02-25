extends Element

const _on: Texture = preload("res://scenes/elements/wire/wire_on.png")
const _off: Texture = preload("res://scenes/elements/wire/wire_off.png")

var _second_area_mouse_entered = false

func _ready() -> void:
	type = Globals.Elements.WIRE

	hide_sprites()

	$Sprite2.material.set_shader_param("texture_size", sprite_size)
	$Sprite2.material.set_shader_param(
		"stripe_color",  Globals.COLORS.SAFE_AREA_ALARM
	)
	$Sprite2.material.set_shader_param("outline_color",  Globals.COLORS.OUTLINE)

func outline(value: bool) -> void:
	$Sprite.material.set_shader_param("is_outlined", value)
	$Sprite2.material.set_shader_param("is_outlined", value)

func set_alpha(value) -> void:
	$Line2D.modulate.a = value
	$Sprite.modulate.a = 1.0
	$Sprite2.modulate.a = 1.0

func show_sprites() -> void:
	$Sprite.show()
	$Sprite2.show()

func hide_sprites() -> void:
	$Sprite.hide()
	$Sprite2.hide()

# create

func start() -> void:
	move_last_point(get_global_mouse_position())
	outline(true)

	var count = 0
	for child in _connectors_children:
		if child.has_connection():
			count += 1

	# stick when start
	if count > 0:
		if count > 1:
			switch_connections(true)
		else:
			switch_connections()
		show_sprites()
		return
	else:
		switch_connections()

	# delete if still not connected_element
	delete_if_more()

func finish() -> bool:
	if (
		$Connectors/In.position.distance_to($Connectors/In2.position)
		< Globals.GAME.MINIMAL_WIRE_LENGTH
	):
		return false

	for child in _connectors_children:
		if child.has_connection():
			switch_connections()

	return true

func delete_if_not_finished() -> void:
	if !finish():
		call_deferred("delete")

func delete_if_less(length: int = Globals.GAME.MINIMAL_WIRE_LENGTH) -> void:
	if (
		$Connectors/In.position.distance_to($Connectors/In2.position)
		< length
	):
		call_deferred("delete")

func delete_if_more(length: int = Globals.GAME.MINIMAL_WIRE_LENGTH) -> void:
	if (
		$Connectors/In.position.distance_to($Connectors/In2.position)
		> length
	):
		call_deferred("delete")

# points

func has_points() -> bool:
	return !($Line2D.points.empty())

func get_points() -> Array:
	return $Line2D.points

func set_points(points: Array) -> void:
	$Line2D.points = points

func add_points(point: Vector2) -> void:
	position = point
	$Line2D.points = PoolVector2Array([Vector2(), Vector2()])

func move_first_point(pos: Vector2) -> void:
	var diff = position - pos
	position = pos
	$Line2D.points[1] += diff

func move_last_point(pos: Vector2) -> void:
	var diff = pos - position
	$Line2D.points[1] = diff

# movement

func is_mouse_entered() -> bool:
	return _is_first_area_mouse_entered || _second_area_mouse_entered

func move_element(pos: Vector2) -> void:
	if _is_first_area_mouse_entered:
		move_first_point(pos)
		switch_connections(true)
	elif _second_area_mouse_entered:
		move_last_point(pos)
		switch_connections(true)

	move_connected_wires()
	delete_if_less()

func switch_connections(drag: bool = false) -> void:
	if !drag:
		_switch_first_points()
		_switch_second_points()

	_sync_node_position(
		[$Connectors/In, $Connectors/Out, $FirstArea, $Sprite], $Line2D.points[0]
	)
	_sync_node_position(
		[$Connectors/In2, $Connectors/Out2, $SecondArea, $Sprite2], $Line2D.points[1]
	)

func check_connect_to_object() -> bool:
	if (
		($Connectors/In.has_connection() || $Connectors/Out.has_connection())
		&& ($Connectors/In2.has_connection() || $Connectors/Out2.has_connection())
	):
		return false
	return true

func check_connect_to_wire(
	connector: Connector, with_connection: bool = true
) -> bool:
	var self_connected: Array = []
	for self_child in get_connectors_children():
		var self_child_connected = self_child.connected_element
		var self_child_connected_area = self_child.connected_area
		if self_child_connected && self_child_connected_area:
			self_connected.append(self_child_connected)
		else:
			self_connected.append(null)

	if connector in [$Connectors/In, $Connectors/Out]:
		if self_connected[0] && self_connected[0].type != Globals.Elements.WIRE:
			return false
		if self_connected[2] && self_connected[2].type != Globals.Elements.WIRE:
			return false

		if (
			with_connection
			&& $Connectors/In.has_connection()
			&& $Connectors/Out.has_connection()
		):
			return false

	elif connector in [$Connectors/In2, $Connectors/Out2]:
		if self_connected[1] && self_connected[1].type != Globals.Elements.WIRE:
			return false
		if self_connected[3] && self_connected[3].type != Globals.Elements.WIRE:
			return false
		if (
			with_connection
			&& $Connectors/In2.has_connection()
			&& $Connectors/Out2.has_connection()
		):
			return false
	return true

# popup

func unlink_wire() -> void:
	if (
		$Connectors/In.is_mouse_entered_connector()
		|| $Connectors/Out.is_mouse_entered_connector()
	):
		for connector in [$Connectors/In, $Connectors/Out]:
			connector.remove_connections_with_elements()
		unlink_points(true)
	elif (
		$Connectors/In2.is_mouse_entered_connector()
		|| $Connectors/Out2.is_mouse_entered_connector()
	):
		for connector in [$Connectors/In2, $Connectors/Out2]:
			connector.remove_connections_with_elements()
		unlink_points(false, true)

func unlink() -> void:
	.unlink()
	unlink_points(true, true)

func unlink_points(is_first: bool = false, is_second: bool = false) -> void:
	if is_first:
		var dir = $Line2D.points[0].direction_to($Line2D.points[1])
		move_first_point(position + dir * Globals.GAME.REPULSE_WIRE_LENGTH)

	if is_second:
		var dir = $Line2D.points[0].direction_to($Line2D.points[1])
		var last_point = $Line2D.to_global($Line2D.points[1])
		move_last_point(last_point - dir * Globals.GAME.REPULSE_WIRE_LENGTH)

	_sync_node_position(
		[$Connectors/In, $Connectors/Out, $FirstArea, $Sprite], $Line2D.points[0]
	)
	_sync_node_position(
		[$Connectors/In2, $Connectors/Out2, $SecondArea, $Sprite2], $Line2D.points[1]
	)

func is_in_first_points(connector: Connector) -> bool:
	return connector in [$Connectors/In, $Connectors/Out]

func is_in_second_points(connector: Connector) -> bool:
	return connector in [$Connectors/In2, $Connectors/Out2]

func _switch_first_points() -> void:
	var in_connected = $Connectors/In.connected_element
	var in_connected_area = $Connectors/In.connected_area
	if in_connected && in_connected_area:
		move_first_point(
			in_connected.to_global(in_connected_area.position)
		)
	var out_connected = $Connectors/Out.connected_element
	var out_connected_area = $Connectors/Out.connected_area
	if out_connected && out_connected_area:
		move_first_point(
			out_connected.to_global(out_connected_area.position)
		)

func _switch_second_points() -> void:
	var in_connected = $Connectors/In2.connected_element
	var in_connected_area = $Connectors/In2.connected_area
	if in_connected && in_connected_area:
		move_last_point(
			in_connected.to_global(in_connected_area.position)
		)
	var out_connected = $Connectors/Out2.connected_element
	var out_connected_area = $Connectors/Out2.connected_area
	if out_connected && out_connected_area:
		move_last_point(
			out_connected.to_global(
				out_connected_area.position
			)
		)

func _sync_node_position(nodes: Array, position: Vector2) -> void:
	for node in nodes:
		node.position = position

# energy loop

func _set_on() -> void:
	$Sprite.texture = self._on_texture
	$Sprite2.texture =self._on_texture
	$Line2D.default_color = Globals.COLORS.ENERGY_ON

func _set_off() -> void:
	$Sprite.texture = self._off_texture
	$Sprite2.texture = self._off_texture
	$Line2D.default_color = Globals.COLORS.ENERGY_OFF

func _has_energy() -> bool:
	for child in _connectors_children:
		if child.connected_has_energy():
			for connector in _connectors_children:
				connector.set_energy(true)
			return true
	return false

func _on_SecondArea_mouse_entered() -> void:
	_second_area_mouse_entered = true

func _on_SecondArea_mouse_exited() -> void:
	_second_area_mouse_entered = false

static func can_connect_to_wire(
	self_connector: Connector, other_connector: Connector
) -> bool:
	var self_connected: Array = []
	for self_child in self_connector.owner.get_connectors_children():
		self_connected.append(self_child.connected_element)

	if !self_connector.owner.check_connect_to_wire(self_connector, false):
		return false

	var other_connected: Array = []
	for other_child in other_connector.owner.get_connectors_children():
		other_connected.append(other_child.connected_element)

	if !other_connector.owner.check_connect_to_wire(other_connector, false):
		return false

	if (
		self_connector.owner in other_connected
		|| other_connector.owner in self_connected
	):
		return false
	return true
