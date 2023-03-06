extends Element

const _on: Texture2D = preload("res://scenes/elements/wire/wire_on.png")
const _off: Texture2D = preload("res://scenes/elements/wire/wire_off.png")

var _is_second_area_mouse_entered = false

func _ready() -> void:
	type = Globals.Elements.WIRE
	super()

	hide_sprites()

	$SecondSprite2D.material.set_shader_parameter(
		"texture_size", sprite_size
	)
	$SecondSprite2D.material.set_shader_parameter(
		"stripe_color",  Globals.COLORS.SAFE_AREA_ALARM
	)
	$SecondSprite2D.material.set_shader_parameter(
		"outline_color",  Globals.COLORS.OUTLINE
	)

func outline(value: bool) -> void:
	$FirstSprite2D.material.set_shader_parameter("is_outlined", value)
	$SecondSprite2D.material.set_shader_parameter("is_outlined", value)

func set_alpha(value) -> void:
	sprite_alpha = value
	$Line2D.modulate.a = value
	$FirstSprite2D.modulate.a = 1.0
	$SecondSprite2D.modulate.a = 1.0

func show_sprites() -> void:
	$FirstSprite2D.show()
	$SecondSprite2D.show()

func hide_sprites() -> void:
	$FirstSprite2D.hide()
	$SecondSprite2D.hide()

# create

func start_drawing() -> void:
	var mouse_pos = get_global_mouse_position()

	if _is_first_area_mouse_entered:
		move_first_point(mouse_pos)
	elif _is_second_area_mouse_entered:
		move_last_point(mouse_pos)

	outline(true)

	var count = 0
	for child in _connectors_children:
		if child.has_connection():
			count += 1

	if count > 0:
		if count > 1:
			# prevent stick when one point has been connected
			switch_connections(true)
		else:
			# stick when point connected first time
			switch_connections()
		show_sprites()
		return
	else:
		switch_connections()

	# delete if wire still not connected
	delete_if_more()

func finish_drawing() -> void:
	if delete_if_less():
		return

	for child in _connectors_children:
		if child.has_connection():
			switch_connections()


func delete_if_less(length: int = Globals.GAME.MINIMAL_WIRE_LENGTH) -> bool:
	if (
		$Connectors/In.position.distance_to($Connectors/In2.position)
		< length
	):
		call_deferred("delete")
		return true
	return false

func delete_if_more(length: int = Globals.GAME.MINIMAL_WIRE_LENGTH) -> void:
	if (
		$Connectors/In.position.distance_to($Connectors/In2.position)
		> length
	):
		call_deferred("delete")

# points

func has_points() -> bool:
	return !($Line2D.points.is_empty())

func get_points() -> Array:
	return $Line2D.points

func set_points(points: Array) -> void:
	$Line2D.points = points

func add_points(point: Vector2) -> void:
	position = point
	$Line2D.points = PackedVector2Array([Vector2(), Vector2()])

func move_first_point(pos: Vector2) -> void:
	var diff = position - pos
	position = pos
	$Line2D.points[1] += diff

func move_last_point(pos: Vector2) -> void:
	var diff = pos - position
	$Line2D.points[1] = diff

# movement

func is_mouse_entered() -> bool:
	return _is_first_area_mouse_entered || _is_second_area_mouse_entered

func is_mouse_intersect_with_shape(mouse_pos: Vector2) -> bool:
	return (
		$FirstSprite2D.get_rect().has_point(
			$FirstSprite2D.to_local(mouse_pos)
		)
		|| $SecondSprite2D.get_rect().has_point(
			$SecondSprite2D.to_local(mouse_pos)
		)
	)

func move_element(pos: Vector2) -> void:
	if _is_first_area_mouse_entered:
		move_first_point(pos)
		switch_connections(true)
	elif _is_second_area_mouse_entered:
		move_last_point(pos)
		switch_connections(true)

	move_connected_wires()

	delete_if_less()

func switch_connections(is_drag: bool = false) -> void:
	if !is_drag:
		# stick to the connectors
		_switch_first_points()
		_switch_second_points()

	_sync_node_position(
		[$Connectors/In, $Connectors/Out, $FirstArea, $FirstSprite2D],
		$Line2D.points[0]
	)
	_sync_node_position(
		[$Connectors/In2, $Connectors/Out2, $SecondArea, $SecondSprite2D],
		$Line2D.points[1]
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
	super()
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
		[$Connectors/In, $Connectors/Out, $FirstArea, $FirstSprite2D],
		$Line2D.points[0]
	)
	_sync_node_position(
		[$Connectors/In2, $Connectors/Out2, $SecondArea, $SecondSprite2D],
		$Line2D.points[1]
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
			out_connected.to_global(out_connected_area.position)
		)

func _sync_node_position(nodes: Array, pos: Vector2) -> void:
	for node in nodes:
		node.position = pos

# energy loop

func _set_on() -> void:
	$FirstSprite2D.texture = self._on_texture
	$SecondSprite2D.texture =self._on_texture
	$Line2D.default_color = Globals.COLORS.ENERGY_ON

func _set_off() -> void:
	$FirstSprite2D.texture = self._off_texture
	$SecondSprite2D.texture = self._off_texture
	$Line2D.default_color = Globals.COLORS.ENERGY_OFF

func _has_energy() -> bool:
	for child in _connectors_children:
		if child.connected_has_energy():
			for connector in _connectors_children:
				connector.set_energy(true)
			return true
	return false

func _on_second_area_mouse_entered() -> void:
	_is_second_area_mouse_entered = true

func _on_second_area_mouse_exited() -> void:
	_is_second_area_mouse_entered = false
