extends Node2D

var _selected_scene: PackedScene = null
var _wire: Element = null

var _selected_elements: Array = []
var _selecting: bool = false
var _select_start = Vector2.ZERO
var _select_rect = RectangleShape2D.new()

var wire_scene: PackedScene = load("res://Scenes/Elements/Wire/Wire.tscn")
var wire_icon: Texture= load("res://Scenes/Elements/Wire/wire_cursor_on.png")

signal scene_deselected
signal clone_pressed
signal menu_poped
signal sprite_showed
signal sprite_hided
signal sprite_texture_saved
signal sprite_texture_removed
signal sprite_position_updated


class SortUtil:
	static func __sort_by_position(a: Element, b: Element):
		if a.position > b.position:
			return true
		return false

	static func __sort_by_rect_bottom_side(a: Element, b: Element):
		var a_sorting_position = Vector2()
		var b_sorting_position = Vector2()
		var a_size = a.sprite_size / 2
		var b_size = b.sprite_size / 2
		a_sorting_position.y = a.position.y + a_size.y
		b_sorting_position.y = b.position.y + b_size.y
#
		if a_sorting_position.y < b_sorting_position.y:
			return true
		return false

func _ready() -> void:
	prints(self.name, "ready")

func __add_child(element: Element) -> void:
	self.__connect_child_signals(element)
	self.add_child(element)

func __connect_child_signals(element: Element) -> void:
	# warning-ignore:return_value_discarded
	element.connect("connector_mouse_entered", self, "_on_Objects_connector_sprite_showed")
	# warning-ignore:return_value_discarded
	element.connect("connector_mouse_exited", self, "_on_Objects_connector_sprite_hided")
	# warning-ignore:return_value_discarded
	element.connect("connector_wire_added", self, "_on_Objects_connector_wire_added")
	# warning-ignore:return_value_discarded
	element.connect("connector_area_entered_received", self, "_on_Objects_connector_area_entered")
	# warning-ignore:return_value_discarded
	element.connect("delete_processed", self, "_on_Element_delete_processed")
	# warning-ignore:return_value_discarded
	element.connect("element_mouse_entered_received", self, "_on_Element_objects_mouse_entered")
	# warning-ignore:return_value_discarded
	element.connect("objects_is_selecting_received", self, "_on_Element_objects_is_selecting")
	# warning-ignore:return_value_discarded
	element.connect("child_moved_to_position", self, "_on_Element_child_moved_to_position")
	# warning-ignore:return_value_discarded
	element.connect("selected_elements_added", self, "_on_Element_selected_elements_added")
	# warning-ignore:return_value_discarded
	element.connect("selected_elements_moved", self, "_on_Element_selected_elements_moved")
	# warning-ignore:return_value_discarded
	element.connect("temporary_wires_cleared", self, "_on_Element_temporary_wires_cleared")
	# warning-ignore:return_value_discarded
	element.connect("elements_sorted", self, "_on_Element_elements_sorted")

func get_mouse_entered_element() -> Element:
	# reverse to get top instanse
	var children: Array = self.get_children()
	children.invert()
	for child in children:
		if child.is_mouse_entered():
			return child
	return null

func is_selecting() -> bool:
	return self._selecting

func set_selecting(value: bool) -> void:
	self._selecting = value

func get_selected_elements() -> Array:
	return self._selected_elements

func has_dragged_elements() -> bool:
	for element in self.get_selected_elements():
		if is_instance_valid(element) && element.is_dragged():
			return true
	return false

func add_selected_element(element: Element) -> void:
	self._selected_elements.append(element)
	element.call_deferred("outline", true)

func set_selected_elements_from_areas(selected_areas: Array) -> void:
	self._selected_elements = []
	for area in selected_areas:
		var element = area.collider.owner
		if not self._selected_elements.has(element):
			self._selected_elements.append(element)
		element.call_deferred("outline", true)

func remove_selected_elements() -> void:
	self.get_tree().call_group_flags(
		SceneTree.GROUP_CALL_DEFAULT, "Elements", "outline", false
	)
	self._selected_elements = []

func has_selected_scene() -> bool:
	return self._selected_scene != null

func set_selected_scene(scene: PackedScene) -> void:
	self._selected_scene = scene
	self.remove_selected_elements()

func get_selected_scene() -> PackedScene:
	return self._selected_scene

func remove_selected_scene() -> void:
	self._selected_scene = null

func _process(_delta: float) -> void:
	for element in self.get_tree().get_nodes_in_group("Energy"):
		if not element.checked:
			element.transfer_energy(element)

	for element in self.get_children():
		if not element.checked:
			element.reset_energy()

	for element in self.get_children():
		element.checked = false

# input
func __setup_wire(event: InputEvent, mouse_pos: Vector2) -> void:
	if not self._wire.has_points():
		self._wire.add_points(mouse_pos)

	if event is InputEventScreenDrag:
		self._wire.start()

	if event is InputEventScreenTouch && not event.pressed:
		if self._wire && is_instance_valid(self._wire):
			self._wire.delete_if_not_finished()
		self._wire = null

func __create_element(mouse_pos: Vector2) -> void:
	var instance = self.get_selected_scene().instance()

	if instance.type == Globals.ELEMENTS.WIRE:
		# instance only when mouse hover on the Connector
		var entered_element = self.get_mouse_entered_element()
		if (
			entered_element
			&& entered_element.is_connector_entered()
		):
			self._wire = instance
			self.__add_child(instance)
	else:
		instance.position = mouse_pos
		self.__add_child(instance)
		self.__sort_objects_for_representation()

func __process_selected_scene(
	scene: PackedScene = null, texture: Texture = null, is_pressed: bool = false
) -> void:

	if is_pressed:
		self.set_selected_scene(scene)
		self.emit_signal("sprite_texture_saved", texture)
	else:
		self.remove_selected_scene()
		self.emit_signal("sprite_hided")
		self.emit_signal("sprite_texture_removed")

func __selecting_init(mouse_pos: Vector2) -> void:
	self._select_start = mouse_pos
	self.remove_selected_elements()

func __select_areas(mouse_pos: Vector2) -> void:
	var _select_end = mouse_pos
	self._select_rect.extents = (_select_end - self._select_start) / 2

	var space = self.get_world_2d().direct_space_state

	var query = Physics2DShapeQueryParameters.new()
	query.collision_layer = 1
	query.collide_with_areas = true
	query.collide_with_bodies = false

	query.set_shape(self._select_rect)
	query.transform = Transform2D(0, (_select_end + self._select_start) / 2)

	self.remove_selected_elements()

	self.set_selected_elements_from_areas(
		space.intersect_shape(query, Globals.GAME.MAXIMUM_ELEMENTS_TO_SELECT)
	)

func _unhandled_input(event: InputEvent) -> void:
	var mouse_pos = self.get_global_mouse_position()
	self.emit_signal("sprite_position_updated", mouse_pos)

	if self.has_selected_scene():
		if self._wire && is_instance_valid(self._wire):
			self.__setup_wire(event, mouse_pos)
		else:
			if (
				event is InputEventMouseButton && event.pressed
			):
				if event.button_index == BUTTON_LEFT:
					self.__create_element(mouse_pos)
				elif event.button_index == BUTTON_RIGHT:
					self.emit_signal("scene_deselected")
					self.__process_selected_scene()

				self.get_tree().set_input_as_handled()
	else:
		if event is InputEventMouseButton:
			if event.button_index == BUTTON_RIGHT && event.pressed:
				var element = self.get_mouse_entered_element()
				if element:
					self.emit_signal(
						"menu_poped", element, len(self.get_selected_elements()) > 1
					)
					self._on_Element_selected_elements_added(element)

		if event is InputEventScreenTouch:
			if event.pressed:
				self.__sort_objects_for_representation()
				self.set_selecting(true)
				self.__selecting_init(mouse_pos)
			else:
				self.set_selecting(false)
				self.update()

		if event is InputEventScreenDrag and self.is_selecting():
			self.__select_areas(mouse_pos)
			self.update()

func _draw():
	if self.is_selecting():
		self.draw_rect(
			Rect2(
				self._select_start,
				self.get_global_mouse_position() - self._select_start
			),
			Color(.5, .5, .5),
			false
		)

func __sort_objects_for_representation():
	var children_top = self.get_children()
	children_top.sort_custom(SortUtil, "__sort_by_rect_bottom_side")
	var size = children_top.size()
	var index = 1
#	print()
	for i in range(size):
		var child_top = children_top[i]
#		if child_top.type == Globals.ELEMENTS.WIRE:
#			continue

		self.move_child(child_top, i)
#		print(child_top, child_top.position)
#		child_top.move_wires_to_position(0)
#		index += 1

#func _notification(what):
#	if what == NOTIFICATION_WM_MOUSE_ENTER:
#		self._is_mouse_in_app = true
#	elif what == NOTIFICATION_WM_MOUSE_EXIT:
#		self._is_mouse_in_app = false

func _on_Elements_button_pressed(scene, icon, pressed) -> void:
	self.__process_selected_scene(scene, icon, pressed)

func _on_Elements_element_added(element: Element) -> void:
	self.__add_child(element)
	self.add_selected_element(element)

func _on_FileMenu_elements_deleted() -> void:
	self.remove_selected_elements()
	for element in self.get_children():
		element.delete(false)

func _on_FileMenu_element_added(element: Element) -> void:
	self.__add_child(element)

func _on_PopupTools_flip_pressed() -> void:
	for element in self.get_selected_elements():
		element.call_deferred("flip")

func _on_PopupTools_clone_pressed() -> void:
	var elements = self.get_selected_elements()
	self.remove_selected_elements()

	var clones = []
	for element in elements:
		self.emit_signal("clone_pressed", element)
		var clone = self.get_child(self.get_child_count()-1)
		clone.set_cloned(true)
		clone.position = element.position
		clone.scale = element.scale
		if clone.type == Globals.ELEMENTS.WIRE:
			clone.set_points(element.get_points())
		clones.append(clone)

	# in separate cycle to save order
	for clone in clones:
		if clone.type == Globals.ELEMENTS.WIRE:
			clone.switch_connections()
			clone.call_deferred("show_sprites")
		else:
			clone.move_wires_on_top()

func _on_PopupTools_unlink_pressed() -> void:
	for element in self.get_selected_elements():
		element.call_deferred("unlink")

func _on_PopupTools_delete_pressed() -> void:
	for element in self.get_selected_elements():
		element.call_deferred("delete", true)
	self.remove_selected_elements()

func _on_Element_delete_processed(element: Element) -> void:
	for child in element._connectors_children:
		child.remove_connections_with_self()

	element.queue_free()

	element._connectors_children = []
	if self.is_a_parent_of(element):
		element.outline(false)
		self.remove_child(element)

func _on_Element_objects_mouse_entered(element: Element) -> void:
	element._is_objects_scene_selected = self.has_selected_scene()
	element._is_objects_has_dragged_elements = self.has_dragged_elements()

func _on_Element_objects_is_selecting(element: Element) -> void:
	element._is_objects_is_selecting = self.is_selecting()

func _on_Element_child_moved_to_position(element: Element, pos = null) -> void:
	if pos != null:
		self.move_child(element, pos)
	else:
		self.move_child(element, self.get_child_count() - 1)

func _on_Element_selected_elements_added(element: Element) -> void:
	if not self.get_selected_elements().has(element):
		self.remove_selected_elements()
		self.add_selected_element(element)

func _on_Element_selected_elements_moved(event: InputEvent) -> void:
	for element in self.get_selected_elements():
		element.position += event.relative * Globals.ACTUAL_ZOOM

func _on_Element_temporary_wires_cleared(element: Element) -> void:
	if self.get_selected_elements().has(element):
		element.clear_temporary_wires()

func _on_Element_elements_sorted() -> void:
	self.__sort_objects_for_representation()

func _on_Objects_connector_wire_added(connector: Connector, other: Connector) -> void:
	var wire = wire_scene.instance()
	self.call_deferred("__add_child", wire)

	var self_pos = connector.owner.to_global(connector.position)
	var other_pos = other.owner.to_global(other.position)
	wire.add_points(self_pos)
	wire.move_first_point(self_pos)
	wire.move_last_point(other_pos)

	var wire_connector = null
	if connector.type == Globals.CONNECTORS.IN:
		wire_connector = wire.get_node("Connectors/Out")
	else:
		wire_connector = wire.get_node("Connectors/In")

	connector.setup_connection(connector, connector.owner, wire_connector, wire)

	if other.type == Globals.CONNECTORS.IN:
		wire_connector = wire.get_node("Connectors/Out2")
	else:
		wire_connector = wire.get_node("Connectors/In2")

	connector.setup_connection(other, other.owner, wire_connector, wire)

	wire.call_deferred("show_sprites")

	# create reference to remove wires
	if connector.owner.is_dragged():
		connector.owner.add_temporary_wire(wire)
	else:
		other.owner.add_temporary_wire(wire)

func _on_Objects_connector_area_entered(connector: Connector) -> void:
	if is_instance_valid(connector):
		connector.objects_selected_elements_size = self.get_selected_elements().size()
		connector.objects_has_dragged_elements = self.has_dragged_elements()

func _on_Objects_connector_sprite_showed(
	element: Element, has_connection: bool
) -> void:

	if self.get_selected_scene() == self.wire_scene:
		self.emit_signal("sprite_showed",  self.wire_icon)

	if element.type == Globals.ELEMENTS.WIRE:
		if not element.check_connect_to_wire(self):
			self.emit_signal("sprite_showed")
	else:
		if has_connection:
			self.emit_signal("sprite_showed")

func _on_Objects_connector_sprite_hided() -> void:
	self.emit_signal("sprite_showed")

