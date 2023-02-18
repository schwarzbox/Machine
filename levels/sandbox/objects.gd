extends Node2D

signal scene_deselected
signal clone_pressed
signal menu_poped
signal sprite_showed
signal sprite_hided
signal sprite_texture_saved
signal sprite_texture_removed
signal sprite_position_updated

var wire_scene: PackedScene = load("res://scenes/elements/wire/wire.tscn")
var wire_icon: Texture= load("res://scenes/elements/wire/wire_cursor_on.png")

var _actual_zoom: float = 1

var _selected_scene: PackedScene = null
var _wire: Element = null

var _selected_elements: Dictionary = {}
var _select_start = Vector2.ZERO
var _select_rect = RectangleShape2D.new()
var _sort_util = load("res://utils/sort_util.gd").new()

var state_util: Reference = load("res://utils/state_util.gd").new()
var idle_state: Reference = state_util.Idle.new(self)
var create_state: Reference = state_util.Create.new(self)
var draw_wire_state: Reference = state_util.DrawWire.new(self)
var select_state: Reference = state_util.Select.new(self)
var drag_wire_state: Reference = state_util.DragWire.new(self)
var drag_element_state: Reference = state_util.DragElement.new(self)
var drag_selected_state: Reference = state_util.DragSelected.new(self)

var _state: Reference = idle_state

func _ready() -> void:
	prints(self.name, "ready")

func _process(_delta: float) -> void:
	for element in self.get_tree().get_nodes_in_group("Energy"):
		if not element.checked:
			element.transfer_energy(element)

	for element in self.get_children():
		if not element.checked:
			element.reset_energy()

	for element in self.get_children():
		element.checked = false

func _unhandled_input(event: InputEvent) -> void:
	var mouse_pos = self.get_global_mouse_position()
	self.emit_signal("sprite_position_updated", mouse_pos)

#	print(_state._name)
	self._state.process_event(event, mouse_pos)

func _draw():
	print(_state._name)
	self._state.draw()

func __add_child(element: Element) -> void:
	self.__connect_child_signals(element)
	self.add_child(element)

func __connect_child_signals(element: Element) -> void:
	# warning-ignore:return_value_discarded
	element.connect("connector_mouse_entered", self, "_on_Objects_connector_sprite_showed")
	# warning-ignore:return_value_discarded
	element.connect("connector_mouse_exited", self, "_on_Objects_connector_sprite_hided")
	# warning-ignore:return_value_discarded
	element.connect("connector_area_entered", self, "_on_Objects_connector_area_entered")
	# warning-ignore:return_value_discarded
	element.connect("delete_processed", self, "_on_Element_delete_processed")
	# warning-ignore:return_value_discarded
	element.connect("child_moved_on_top", self, "_on_Element_child_moved_on_top")
	# warning-ignore:return_value_discarded
	element.connect("safe_area_entered", self, "_on_Element_safe_area_processed")
		# warning-ignore:return_value_discarded
	element.connect("safe_area_exited", self, "_on_Element_safe_area_processed")

func set_state(state: Reference) -> void:
	self._state = state

func is_drag_selected_state() -> bool:
	return (self._state == drag_selected_state)

func is_drag_element_state() -> bool:
	return (self._state == drag_element_state)

func is_draw_wire_state() -> bool:
	return (self._state == draw_wire_state)

func get_mouse_entered_element() -> Element:
	# reverse to get top instanse
	var children: Array = self.get_children()
	children.invert()
	for child in children:
		if child.is_mouse_entered():
			return child
	return null

func has_safe_area_entered_element() -> bool:
	var children: Array = self.get_children()
	for child in children:
		if child.is_safe_area_entered():
			return true
	return false

func get_selected_elements() -> Dictionary:
	return self._selected_elements

func add_selected_element(element: Element) -> void:
	var element_id = element.get_instance_id()
	self._selected_elements[element_id] = element
	element.call_deferred("outline", true)

func set_selected_elements_from_areas(selected_areas: Array) -> void:
	for area in selected_areas:
		var element = area.collider.owner
		# to protect from wrong placement
		element.last_valid_position = element.position
		if not self._selected_elements.has(element):
			self.add_selected_element(element)

func remove_selected_element(element: Element) -> void:
	var elements = self.get_selected_elements()
	elements.erase(element.get_instance_id())

func remove_selected_elements() -> void:
	self.get_tree().call_group_flags(
		SceneTree.GROUP_CALL_DEFAULT, "Elements", "outline", false
	)
	# to correctly reconect wires after cloning
	self.get_tree().call_group_flags(
		SceneTree.GROUP_CALL_DEFAULT, "Elements", "set_cloned", false
	)

	self._selected_elements = {}

func update_selected_elements_last_valid_position():
	for element in self.get_selected_elements().values():
		element.last_valid_position = element.position

func re_add_selected_element(element: Element) -> void:
	element.last_valid_position = element.position
	if not self.get_selected_elements().has(element.get_instance_id()):
		self.remove_selected_elements()
		self.add_selected_element(element)

func has_selected_scene() -> bool:
	return self._selected_scene != null

func set_selected_scene(scene: PackedScene) -> void:
	self._selected_scene = scene

func get_selected_scene() -> PackedScene:
	return self._selected_scene

func is_wire_selected_scene() -> bool:
	return (self._selected_scene == self.wire_scene)

func remove_selected_scene() -> void:
	self._selected_scene = null

func sort_objects_for_representation(without_wire: bool = false):
	var children_top = self.get_children()
	children_top.sort_custom(self._sort_util, "__sort_by_rect_bottom_side")
	for i in range(children_top.size()):
		var child_top = children_top[i]
		if without_wire && child_top.type == Globals.Elements.WIRE:
			continue
		else:
			self.move_child(child_top, i)

func show_sprite_icon(element: Element, connector: Connector):
	var icon: Texture = self.wire_icon if self.is_wire_selected_scene() else null

	if element.type == Globals.Elements.WIRE:
		if element.check_connect_to_wire(connector):
			self.emit_signal("sprite_showed",  icon)
	else:
		if !connector.has_connection():
			self.emit_signal("sprite_showed",  icon)

#func _notification(what):
#	if what == NOTIFICATION_WM_MOUSE_ENTER:
#		self._is_mouse_in_app = true
#	elif what == NOTIFICATION_WM_MOUSE_EXIT:
#		self._is_mouse_in_app = false

func _on_Camera2D_zoom_changed(value: float) -> void:
	self._actual_zoom = value

func _on_Elements_button_pressed(scene: PackedScene, icon: Texture, pressed: bool) -> void:
	if pressed:
		self._state.process_set_selected_scene(scene, icon)
	else:
		self._state.process_remove_selected_scene()

func _on_Elements_element_added(element: Element) -> void:
	self.__add_child(element)
	# to protect from wrong placement
	element.last_valid_position = element.position
	self.add_selected_element(element)

func _on_FileMenu_elements_deleted() -> void:
	for element in self.get_children():
		element.delete(false)

func _on_FileMenu_element_added(element: Element) -> void:
	self.__add_child(element)

func _on_PopupTools_flip_pressed() -> void:
	for element in self.get_selected_elements().values():
		element.call_deferred("flip")

func _on_PopupTools_clone_pressed() -> void:
	var elements = self.get_selected_elements().values()
	self.remove_selected_elements()

	var clones = []
	for element in elements:
		self.emit_signal("clone_pressed", element)
		var clone = self.get_child(self.get_child_count()-1)
		clone.set_cloned(true)
		clone.position = element.position + Vector2(32, 32)
		clone.scale = element.scale
		if clone.type == Globals.Elements.WIRE:
			clone.set_points(element.get_points())
		clones.append(clone)

	# in separate cycle to save order
	for clone in clones:
		if clone.type == Globals.Elements.WIRE:
			clone.switch_connections()
			clone.call_deferred("show_sprites")
		else:
			clone.move_wires_on_top()

func _on_PopupTools_unlink_pressed() -> void:
	for element in self.get_selected_elements().values():
		element.call_deferred("unlink")

func _on_PopupTools_delete_pressed() -> void:
	for element in self.get_selected_elements().values():
		element.call_deferred("delete", true)

func _on_Element_delete_processed(element: Element) -> void:
	self.remove_selected_element(element)

	for child in element._connectors_children:
		child.remove_connections_with_self()

	element.queue_free()

	element._connectors_children = []
	if self.is_a_parent_of(element):
		element.outline(false)
		self.remove_child(element)

func _on_Element_child_moved_on_top(element: Element) -> void:
	self.move_child(element, self.get_child_count() - 1)

func _on_Element_safe_area_processed(
	element: Element, area: Area2D, is_entered: bool
) -> void:
	if (
		element.type == Globals.Elements.WIRE
		|| area.owner.type == Globals.Elements.WIRE
		|| self.is_wire_selected_scene()
	):
		return

	if is_entered:
		element._safe_areas_element_entered[area] = area
		element.safe_area_alarm(true)
	else:
		element._safe_areas_element_entered.erase(area)
		if element.is_safe_area_entered():
			return
		element.safe_area_alarm(false)

func _on_Objects_connector_sprite_showed(
	element: Element, connector: Connector
) -> void:

	if self.is_draw_wire_state():
		return

	self.show_sprite_icon(element, connector)

func _on_Objects_connector_sprite_hided() -> void:
	self.emit_signal("sprite_showed")

func _on_Objects_connector_area_entered(
	connector: Connector, other: Connector
) -> void:

	if (
		connector.owner.type == Globals.Elements.WIRE
		&& other.owner.type == Globals.Elements.WIRE
	):
		if self.is_drag_element_state():
			return

		if !connector.owner.can_connect_to_wire(connector, other):
			return

		connector.setup_connection(connector, connector.owner, other, other.owner)
	elif (
		connector.owner.type == Globals.Elements.WIRE
		|| other.owner.type == Globals.Elements.WIRE
	):
		if self.is_drag_element_state():
			return

		if connector.owner.type == Globals.Elements.WIRE:
			if !connector.owner.check_connect_to_object():
				return

		if other.owner.type == Globals.Elements.WIRE:
			if !other.owner.check_connect_to_object():
				return

		connector.setup_connection(connector, connector.owner, other, other.owner)
	else:

		if self.is_drag_selected_state():
			return

		# auto connection
		var wire = wire_scene.instance()
		self.call_deferred("__add_child", wire)

		var self_pos = connector.owner.to_global(connector.position)
		var other_pos = other.owner.to_global(other.position)
		wire.add_points(self_pos)
		wire.move_first_point(self_pos)
		wire.move_last_point(other_pos)

		var wire_connector = null
		if connector.type == Globals.Connectors.IN:
			wire_connector = wire.get_node("Connectors/Out")
		else:
			wire_connector = wire.get_node("Connectors/In")

		connector.setup_connection(connector, connector.owner, wire_connector, wire)

		if other.type == Globals.Connectors.IN:
			wire_connector = wire.get_node("Connectors/Out2")
		else:
			wire_connector = wire.get_node("Connectors/In2")

		connector.setup_connection(other, other.owner, wire_connector, wire)

		wire.call_deferred("show_sprites")

		# create reference to remove wires
		if connector.owner.is_mouse_entered():
			connector.owner.add_temporary_wire(wire)
		else:
			other.owner.add_temporary_wire(wire)



