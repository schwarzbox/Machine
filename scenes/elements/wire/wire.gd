extends Element

const _on: Texture2D = preload("res://scenes/elements/wire/wire_on.png")
const _off: Texture2D = preload("res://scenes/elements/wire/wire_off.png")

var _is_second_area_mouse_entered = false

func _ready() -> void:
	type = Globals.Elements.WIRE
	super()

	$SecondSprite2D.material.set_shader_parameter("texture_size", sprite_size)
	$SecondSprite2D.material.set_shader_parameter(
		"stripe_color",  Globals.COLORS.SAFE_AREA_ALARM
	)
	$SecondSprite2D.material.set_shader_parameter(
		"outline_color",  Globals.COLORS.OUTLINE
	)

	# restore notifiers after load
	if $Line2D.points:
		_sync_visible_notifier_size()

	# set default alpha for line
	$Line2D.modulate.a = Globals.GAME.WIRE_ALPHA
	hide_sprites()
	# to correctly connect wire when draw
	disable_first_connectors()

func outline(value: bool) -> void:
	$FirstSprite2D.material.set_shader_parameter("is_outlined", value)
	$SecondSprite2D.material.set_shader_parameter("is_outlined", value)

func show_sprites() -> void:
	$FirstSprite2D.show()
	$SecondSprite2D.show()

func hide_sprites() -> void:
	$FirstSprite2D.hide()
	$SecondSprite2D.hide()

func visible_show() -> void:
	$Line2D.show()
	$FirstArea.show()
	$SecondArea.show()
	show_sprites()
	$SafeArea.show()
	$Connectors.show()

func visible_hide() -> void:
	$Line2D.hide()
	$FirstArea.hide()
	$SecondArea.hide()
	hide_sprites()
	$SafeArea.hide()
	$Connectors.hide()

func is_first_connectors_disabled() -> bool:
	return $Connectors/In/CollisionShape2D.disabled

func enable_first_connectors() -> void:
	$Connectors/In/CollisionShape2D.set_deferred("disabled", false)
	$Connectors/Out/CollisionShape2D.set_deferred("disabled", false)

func disable_first_connectors() -> void:
	$Connectors/In/CollisionShape2D.set_deferred("disabled", true)
	$Connectors/Out/CollisionShape2D.set_deferred("disabled", true)

# create

func start_drawing(mouse_pos: Vector2, direction: Globals.Directions) -> void:
	if direction == Globals.Directions.HORIZONTAL:
		mouse_pos.y = to_global($Line2D.points[1]).y
	elif direction == Globals.Directions.VERTICAL:
		mouse_pos.x = to_global($Line2D.points[1]).x

	move_first_point(mouse_pos)

	var connected_count = 0
	for child in connectors_children:
		if child.has_connection():
			connected_count += 1

	if connected_count > 0:
		if connected_count > 1:
			# prevent stick when one point has been connected
			sync_wire_nodes(false)
		else:
			# stick when point connected first time
			sync_wire_nodes()
			show_sprites()
		# to correctly connect wire when draw
		if is_first_connectors_disabled:
			call_deferred("enable_first_connectors")
		return

	# delete if wire still not connected
	delete_if_more()

func finish_drawing() -> void:
	if delete_if_less():
		return

	sync_wire_nodes()

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
		sync_wire_nodes(false)
	elif _is_second_area_mouse_entered:
		move_last_point(pos)
		sync_wire_nodes(false)

	move_connected_wires()

	# to delete self
	delete_if_less()

func sync_wire_nodes(is_sticked: bool = true) -> void:
	if is_sticked:
		# stick to the connectors
		_stick_first_points()
		_stick_second_points()

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

	for self_child in connectors_children:
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

func _stick_first_points() -> void:
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

func _stick_second_points() -> void:
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

func _update_connected_wire(element: Element) -> void:
	super(element)
	element.delete_if_less()

# notifier

func _sync_visible_notifier_size() -> void:
	var v_sign = sign($Line2D.points[1])
	if v_sign.x < 0:
		$VisibleOnScreenNotifier2D.rect.position.x = (
			$Line2D.points[1].x - half_sprite_size.x
		)
	if v_sign.y < 0:
		$VisibleOnScreenNotifier2D.rect.position.y = (
			$Line2D.points[1].y - half_sprite_size.y
		)
	$VisibleOnScreenNotifier2D.rect.size = abs($Line2D.points[1]) + sprite_size

func _sync_node_position(nodes: Array, pos: Vector2) -> void:
	for node in nodes:
		node.position = pos
	_sync_visible_notifier_size()

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
	for child in connectors_children:
		if child.connected_has_energy():
			for connector in connectors_children:
				connector.set_energy(true)
			return true
	return false

func _on_second_area_mouse_entered() -> void:
	_is_second_area_mouse_entered = true

func _on_second_area_mouse_exited() -> void:
	_is_second_area_mouse_entered = false
