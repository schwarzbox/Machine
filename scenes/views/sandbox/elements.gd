extends Node2D

# ElementMenu
signal clone_pressed
# Cursor
signal cursor_shape_updated
# PopupTool
signal menu_poped
# ElementMenu
signal scene_deselected
# Cursor
signal sprite_hided
signal sprite_position_updated
signal sprite_showed
signal sprite_texture_removed
signal sprite_texture_saved

var actual_zoom: float = 1

var active_wire: Element = null
var selected_scene: PackedScene = null

var selected_elements: Dictionary = {}
var selection_start = Vector2.ZERO
var selection_rectangle = RectangleShape2D.new()

# states
var state_util: ObjectState = load("res://utils/state_util.gd").new()
var idle_state: RefCounted = state_util.Idle.new(self)
var create_state: RefCounted = state_util.Create.new(self)
var draw_wire_state: RefCounted = state_util.DrawWire.new(self)
var select_state: RefCounted = state_util.Select.new(self)
var drag_wire_state: RefCounted = state_util.DragWire.new(self)
var drag_element_state: RefCounted = state_util.DragElement.new(self)
var drag_selected_state: RefCounted = state_util.DragSelected.new(self)
var active_state: RefCounted = idle_state

var _wire_scene: PackedScene = load("res://scenes/elements/wire/wire.tscn")
var _wire_icon: Texture2D= load("res://scenes/elements/wire/wire_cursor_on.png")

var _sort_util: SortUtil = load("res://utils/sort_util.gd").new()

func _ready() -> void:
	prints(name, "ready")

func _process(_delta: float) -> void:
	for element in get_tree().get_nodes_in_group("Energy"):
		if not element.is_checked:
			element.transfer_energy(element)

	for element in get_children():
		if not element.is_checked:
			element.reset_energy()

	for element in get_children():
		element.is_checked = false

func _unhandled_input(event: InputEvent) -> void:
	var mouse_pos = get_global_mouse_position()
	emit_signal("sprite_position_updated", mouse_pos)
#	print(active_state._name)
	active_state.process_event(event, mouse_pos)

func _draw():
	active_state.draw()

#func _notification(what):
#	if what == NOTIFICATION_WM_MOUSE_ENTER:
#		_is_mouse_in_app = true
#	elif what == NOTIFICATION_WM_MOUSE_EXIT:
#		_is_mouse_in_app = false

func add_child_element(element: Element) -> void:
	# warning-ignore:return_value_discarded
	element.connect("delete_processed", _on_element_delete_processed)
	# warning-ignore:return_value_discarded
	element.connect("child_moved_on_top", _on_element_child_moved_on_top)
	# warning-ignore:return_value_discarded
	element.connect("safe_area_entered", _on_element_safe_area_processed)
	# warning-ignore:return_value_discarded
	element.connect("safe_area_exited", _on_element_safe_area_processed)
	# warning-ignore:return_value_discarded
	element.connect("connector_mouse_entered", _on_objects_connector_sprite_showed)
	# warning-ignore:return_value_discarded
	element.connect("connector_mouse_exited", _on_objects_connector_sprite_hided)
	# warning-ignore:return_value_discarded
	element.connect("connector_area_entered", _on_objects_connector_area_entered)
	add_child(element)

func show_sprite_icon(element: Element, connector: Connector):
	var icon: Texture2D = _wire_icon if _is_wire_selected_scene() else null

	if element.type == Globals.Elements.WIRE:
		if element.check_connect_to_wire(connector):
			emit_signal("sprite_showed",  icon)
	else:
		if !connector.has_connection():
			emit_signal("sprite_showed",  icon)

func get_mouse_entered_element() -> Element:
	# reverse to get top instanse
	var children: Array = get_children()
	children.reverse()

	for child in children:
		if child.is_mouse_entered():
			return child
	return null

func has_safe_area_entered_element() -> bool:
	var children: Array = get_children()
	for child in children:
		if child.is_safe_area_entered():
			return true
	return false

func sort_objects_for_representation():
	var children_top = get_children()
	children_top.sort_custom(_sort_util._sort_by_rect_bottom_side)
	for i in range(children_top.size()):
		var child_top = children_top[i]
		var index = i
		if child_top.type == Globals.Elements.WIRE:
			index = 0
		move_child(child_top, index)

func set_selected_scene(scene: PackedScene, tx: Texture2D) -> void:
	selected_scene = scene
	remove_selected_elements()
	emit_signal(
		"sprite_texture_saved",
		tx,
		# save polygon data to check safe area
		scene.instantiate().get_node(^"SafeArea/CollisionShape2D").shape.size,
		# is_element to use BW cursors
		false if _is_wire_selected_scene() else true
	)

func remove_selected_scene() -> void:
	emit_signal("scene_deselected")
	selected_scene = null
	emit_signal("sprite_hided")
	emit_signal("sprite_texture_removed")

func set_selected_elements_from_areas(selected_areas: Array) -> void:
	for area in selected_areas:
		var element = area.collider.owner
		# to protect from wrong placement
		element.last_valid_position = element.position
		if !selected_elements.has(element):
			_add_selected_element(element)

func remove_selected_elements() -> void:
	get_tree().call_group_flags(
		SceneTree.GROUP_CALL_DEFAULT, "Elements", "outline", false
	)
	# to correctly reconect wires after cloning
	get_tree().call_group_flags(
		SceneTree.GROUP_CALL_DEFAULT, "Elements", "set_is_cloned", false
	)

	selected_elements = {}

func update_selected_elements_last_valid_position():
	for element in selected_elements.values():
		element.last_valid_position = element.position

func re_add_selected_element(element: Element) -> void:
	element.last_valid_position = element.position
	if !selected_elements.has(element.get_instance_id()):
		remove_selected_elements()
		_add_selected_element(element)

func _add_selected_element(element: Element) -> void:
	var element_id = element.get_instance_id()
	selected_elements[element_id] = element
	element.call_deferred("outline", true)

func _remove_selected_element(element: Element) -> void:
	# warning-ignore:return_value_discarded
	selected_elements.erase(element.get_instance_id())

func _is_drag_selected_state() -> bool:
	return (active_state == drag_selected_state)

func _is_drag_element_state() -> bool:
	return (active_state == drag_element_state)

func _is_draw_wire_state() -> bool:
	return (active_state == draw_wire_state)

func _is_wire_selected_scene() -> bool:
	return (selected_scene == _wire_scene)

func _on_file_menu_file_loaded() -> void:
	sort_objects_for_representation()

func _on_camera_2d_zoom_changed(value: float) -> void:
	actual_zoom = value

func _on_element_menu_button_pressed(scene: PackedScene, icon: Texture2D, pressed: bool) -> void:
	if pressed:
		active_state.process_set_selected_scene(scene, icon)
	else:
		active_state.process_remove_selected_scene()

func _on_element_menu_element_added(element: Element) -> void:
	add_child_element(element)
	# to protect from wrong placement
	element.last_valid_position = element.position
	_add_selected_element(element)

func _on_file_menu_elements_deleted() -> void:
	for element in get_children():
		element.delete(false)

func _on_file_menu_element_added(element: Element) -> void:
	add_child_element(element)

func _on_popup_tool_rotate_cw_pressed() -> void:
	for element in selected_elements.values():
		element.call_deferred("rotate_cw")

func _on_popup_tool_rotate_ccw_pressed() -> void:
	for element in selected_elements.values():
		element.call_deferred("rotate_ccw")

func _on_popup_tool_clone_pressed() -> void:
	var elements = selected_elements.values()
	remove_selected_elements()

	var clones = []
	for element in elements:
		emit_signal("clone_pressed", element)
		var clone = get_child(get_child_count()-1)

		clone.set_is_cloned(true)

		clone.position = element.position + Vector2(32, 32)
		clone.scale = element.scale
		clone.rotation = element.rotation
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

func _on_popup_tool_unlink_pressed() -> void:
	for element in selected_elements.values():
		element.call_deferred("unlink")

func _on_popup_tool_delete_pressed() -> void:
	for element in selected_elements.values():
		element.call_deferred("delete", true)

func _on_element_delete_processed(element: Element) -> void:
	_remove_selected_element(element)

	for child in element.get_connectors_children():
		child.remove_connections_with_self()

	element.queue_free()

	element.clear_connectors_children()
	if is_ancestor_of(element):
		element.outline(false)
		remove_child(element)

func _on_element_child_moved_on_top(element: Element) -> void:
	move_child(element, get_child_count() - 1)

func _on_element_safe_area_processed(
	element: Element, area: Area2D, is_entered: bool
) -> void:
	if (
		element.type == Globals.Elements.WIRE
		|| area.owner.type == Globals.Elements.WIRE
		|| _is_wire_selected_scene()
	):
		return

	if is_entered:
		element.set_safe_area_entered(area)
		element.safe_area_alarm(true)
	else:
		# warning-ignore:return_value_discarded
		element.remove_safe_area_entered(area)
		if element.is_safe_area_entered():
			return
		element.safe_area_alarm(false)

func _on_objects_connector_sprite_showed(
	element: Element, connector: Area2D
) -> void:

	if _is_draw_wire_state():
		return

	show_sprite_icon(element, connector)

func _on_objects_connector_sprite_hided() -> void:
	emit_signal("sprite_showed")

func _on_objects_connector_area_entered(
	connector: Connector, other: Connector
) -> void:

	if (
		connector.owner.type == Globals.Elements.WIRE
		&& other.owner.type == Globals.Elements.WIRE
	):
		if _is_drag_element_state():
			return

		if !Connector.can_connect_to_wire(connector, other):
			return

		Connector.setup_connection(connector, connector.owner, other, other.owner)
	elif (
		connector.owner.type == Globals.Elements.WIRE
		|| other.owner.type == Globals.Elements.WIRE
	):
		if _is_drag_element_state():
			return

		if connector.owner.type == Globals.Elements.WIRE:
			if !connector.owner.check_connect_to_object():
				return

		if other.owner.type == Globals.Elements.WIRE:
			if !other.owner.check_connect_to_object():
				return

		Connector.setup_connection(connector, connector.owner, other, other.owner)
	else:
		if _is_drag_selected_state():
			return

		# auto connection
		var wire = _wire_scene.instantiate()
		call_deferred("add_child_element", wire)

		var self_pos = connector.owner.to_global(connector.position)
		var other_pos = other.owner.to_global(other.position)
		wire.add_points(self_pos)
		wire.move_first_point(self_pos)
		wire.move_last_point(other_pos)

		var wire_connector = null
		if connector.type == Globals.Connectors.IN:
			wire_connector = wire.get_node(^"Connectors/Out")
		else:
			wire_connector = wire.get_node(^"Connectors/In")

		Connector.setup_connection(connector, connector.owner, wire_connector, wire)

		if other.type == Globals.Connectors.IN:
			wire_connector = wire.get_node(^"Connectors/Out2")
		else:
			wire_connector = wire.get_node(^"Connectors/In2")

		Connector.setup_connection(other, other.owner, wire_connector, wire)

		# sync sprites
		wire.switch_connections(true)

		wire.call_deferred("show_sprites")

		# create reference to remove wires
		if connector.owner.is_mouse_entered():
			connector.owner.add_temporary_wire(wire)
		else:
			other.owner.add_temporary_wire(wire)
