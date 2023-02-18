extends Element

var _on: Texture = preload("res://scenes/elements/wire/wire_on.png")
var _off: Texture = preload("res://scenes/elements/wire/wire_off.png")

var _second_area_mouse_entered = false


func _ready() -> void:
	self.type = Globals.Elements.WIRE

	self.hide_sprites()

	$Sprite2.material.set_shader_param("texture_size",  self.sprite_size)
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

# energy loop

func _set_on() -> void:
	$Sprite.texture = self._on_texture
	$Sprite2.texture =self._on_texture
	$Line2D.default_color = Globals.COLORS.ENERGY_ON

func _set_off() -> void:
	$Sprite.texture = self._off_texture
	$Sprite2.texture = self._off_texture
	$Line2D.default_color = Globals.COLORS.ENERGY_OFF

func __has_energy() -> bool:
	for child in self._connectors_children:
		var child_connected_area = child.get_connected_area()
		if (
			child_connected_area
			&& child_connected_area.get_energy()
		):
			$Connectors/In.set_energy(true)
			$Connectors/In2.set_energy(true)
			$Connectors/Out.set_energy(true)
			$Connectors/Out2.set_energy(true)
			return true
	return false

# management

func unlink_wire() -> void:
	if (
		$Connectors/In.is_mouse_entered()
		|| $Connectors/Out.is_mouse_entered()
	):
		for connector in [$Connectors/In, $Connectors/Out]:
			connector.remove_connections_with_elements()
		self.unlink_points(true)
	elif (
		$Connectors/In2.is_mouse_entered()
		|| $Connectors/Out2.is_mouse_entered()
	):
		for connector in [$Connectors/In2, $Connectors/Out2]:
			connector.remove_connections_with_elements()
		self.unlink_points(false, true)

func unlink() -> void:
	.unlink()
	unlink_points(true, true)

func move_element(pos: Vector2) -> void:
	if _first_area_mouse_entered:
		move_first_point(pos)
		switch_connections(true)
	elif _second_area_mouse_entered:
		move_last_point(pos)
		switch_connections(true)

	move_connected_wires()
	delete_if_less()

func is_mouse_entered():
	return _first_area_mouse_entered || _second_area_mouse_entered

# wire

func show_sprites():
	$Sprite.show()
	$Sprite2.show()

func hide_sprites():
	$Sprite.hide()
	$Sprite2.hide()


func is_in_first_points(connector: Connector):
	return connector in [$Connectors/In, $Connectors/Out]

func is_in_second_points(connector: Connector):
	return connector in [$Connectors/In2, $Connectors/Out2]

func _sync_node_position(nodes: Array, position: Vector2) -> void:
	for node in nodes:
		node.position = position

func unlink_points(is_first: bool = false, is_second: bool = false):
	if is_first:
		var dir = $Line2D.points[0].direction_to($Line2D.points[1])
		move_first_point(position + dir * Globals.GAME.REPULSE_WIRE_LENGTH)

	if is_second:
		var dir = $Line2D.points[0].direction_to($Line2D.points[1])
		var last_point = $Line2D.to_global($Line2D.points[1])
		move_last_point(last_point - dir * Globals.GAME.REPULSE_WIRE_LENGTH)

	self._sync_node_position(
		[$Connectors/In, $Connectors/Out, $FirstArea, $Sprite], $Line2D.points[0]
	)
	self._sync_node_position(
		[$Connectors/In2, $Connectors/Out2, $SecondArea, $Sprite2], $Line2D.points[1]
	)

func _switch_first_points() -> void:
	var in_connected = $Connectors/In.get_connected()
	var in_connected_area = $Connectors/In.get_connected_area()
	if in_connected && in_connected_area:
		self.move_first_point(
			in_connected.to_global(in_connected_area.position)
		)
	var out_connected = $Connectors/Out.get_connected()
	var out_connected_area = $Connectors/Out.get_connected_area()
	if out_connected && out_connected_area:
		self.move_first_point(
			out_connected.to_global(out_connected_area.position)
		)

func _switch_second_points() -> void:
	var in_connected = $Connectors/In2.get_connected()
	var in_connected_area = $Connectors/In2.get_connected_area()
	if in_connected && in_connected_area:
		self.move_last_point(
			in_connected.to_global(in_connected_area.position)
		)
	var out_connected = $Connectors/Out2.get_connected()
	var out_connected_area = $Connectors/Out2.get_connected_area()
	if out_connected && out_connected_area:
		self.move_last_point(
			out_connected.to_global(
				out_connected_area.position
			)
		)

func switch_connections(drag: bool = false) -> void:
	if not drag:
		self._switch_first_points()
		self._switch_second_points()

	self._sync_node_position(
		[$Connectors/In, $Connectors/Out, $FirstArea, $Sprite], $Line2D.points[0]
	)
	self._sync_node_position(
		[$Connectors/In2, $Connectors/Out2, $SecondArea, $Sprite2], $Line2D.points[1]
	)

# points

func has_points() -> bool:
	return !($Line2D.points.empty())

func get_points() -> Array:
	return $Line2D.points

func set_points(points: Array) -> void:
	$Line2D.points = points

func add_points(point: Vector2) -> void:
	self.position = point
	$Line2D.points = PoolVector2Array([Vector2(), Vector2()])

func move_first_point(position: Vector2) -> void:
	var diff = self.position - position
	self.position = position
	$Line2D.points[1] += diff

func move_last_point(position: Vector2) -> void:
	var diff = position - self.position
	$Line2D.points[1] = diff

# create

func start() -> void:
	self.move_last_point(self.get_global_mouse_position())
	self.outline(true)

	var count = 0
	for child in self._connectors_children:
		if child.has_connection():
			count += 1

	# stick when start
	if count > 0:
		if count > 1:
			self.switch_connections(true)
		else:
			self.switch_connections()
		self.show_sprites()
		return
	else:
		self.switch_connections()

	# delete if still not _connected
	self.delete_if_more()

func finish() -> bool:
	if (
		$Connectors/In.position.distance_to($Connectors/In2.position)
		< Globals.GAME.MINIMAL_WIRE_LENGTH
	):
		return false

	for child in self._connectors_children:
		if child.has_connection():
			self.switch_connections()

	return true

func delete_if_not_finished() -> void:
	if not self.finish():
		self.call_deferred("delete")

func delete_if_less(length: int = Globals.GAME.MINIMAL_WIRE_LENGTH) -> void:
	if (
		$Connectors/In.position.distance_to($Connectors/In2.position)
		< length
	):
		self.call_deferred("delete")

func delete_if_more(length: int = Globals.GAME.MINIMAL_WIRE_LENGTH) -> void:
	if (
		$Connectors/In.position.distance_to($Connectors/In2.position)
		> length
	):
		self.call_deferred("delete")

static func can_connect_to_wire(self_connector: Connector, other_connector: Connector) -> bool:
	var self_connected: Array = []
	for self_child in self_connector.owner.get_connectors_children():
		self_connected.append(self_child.get_connected())

	if not self_connector.owner.check_connect_to_wire(self_connector, false):
		return false

	var other_connected: Array = []
	for other_child in other_connector.owner.get_connectors_children():
		other_connected.append(other_child.get_connected())

	if not other_connector.owner.check_connect_to_wire(other_connector, false):
		return false

	if self_connector.owner in other_connected || other_connector.owner in self_connected:
		return false

	return true

func check_connect_to_object() -> bool:
	if (
		($Connectors/In.has_connection() || $Connectors/Out.has_connection())
		&& ($Connectors/In2.has_connection() || $Connectors/Out2.has_connection())
	):
		return false
	return true

func check_connect_to_wire(connector: Connector, with_connection: bool = true) -> bool:
	var self_connected: Array = []
	for self_child in self.get_connectors_children():
		var self_child_connected = self_child.get_connected()
		var self_child_connected_area = self_child.get_connected_area()
		if self_child_connected and self_child_connected_area:
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

func _on_SecondArea_mouse_entered() -> void:
	self._second_area_mouse_entered = true

func _on_SecondArea_mouse_exited() -> void:
	self._second_area_mouse_entered = false
