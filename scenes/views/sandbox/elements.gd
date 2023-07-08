extends Node2D

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
# Minimap
signal minimap_icons_updated
signal minimap_frame_updated
signal minimap_reseted
signal minimap_disabled

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

var selected_elements: Dictionary = {}
var selection_start = Vector2.ZERO
var selection_rectangle = RectangleShape2D.new()

var _selected_scene: PackedScene = null: get = get_selected_scene, set = set_selected_scene
var _active_wire: Element = null: get = get_active_wire, set = set_active_wire
var _active_connectors: Dictionary = {}

var _wire_scene: PackedScene = Globals.ELEMENT_SCENES["Wire"][0]
var _wire_icon: Texture2D= Globals.ELEMENT_SCENES["Wire"][2]

# TODO
# var _sort_util: SortUtil = load("res://utils/sort_util.gd").new()
var _clone_util: CloneUtil = load("res://utils/clone_util.gd").new()

# Camera
var _actual_zoom: float = 1: get = get_actual_zoom
var _actual_offset: Vector2 = Vector2()

# Minimap
var _minimap_util: MinimapUtil = load("res://utils/minimap_util.gd").new()
var _is_minimap_entered: bool = false: get = is_minimap_entered


func _ready() -> void:
	prints(name, "ready")

	# viewport changes size
	get_tree().get_root().connect("size_changed", _on_viewport_size_changed)

func _process(_delta: float) -> void:
	for element in get_tree().get_nodes_in_group("Energy"):
		if !element.is_checked():
			element.transfer_energy(element)

	_minimap_util.reset_minimap_icons()

	for element in get_children():
		if !element.is_checked():
			element.reset_energy()

		_minimap_util.set_minimap_icons(element)

	_update_minimap()

	get_tree().call_group("Elements", "set_is_checked", false)


func _unhandled_input(event: InputEvent) -> void:
	var mouse_pos = get_global_mouse_position()
	emit_signal("sprite_position_updated", mouse_pos)
#	print(active_state._name)
	active_state.process_event(event, mouse_pos)

func _draw():
	active_state.draw()

#func _notification(what):
#	if what == NOTIFICATION_WM_MOUSE_ENTER:
#		print(what)
#	elif what == NOTIFICATION_WM_MOUSE_EXIT:
#		print(what)

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
	element.connect("connector_mouse_entered", _on_objects_connector_mouse_entered)
	# warning-ignore:return_value_discarded
	element.connect("connector_mouse_exited", _on_objects_connector_mouse_exited)
	# warning-ignore:return_value_discarded
	element.connect("connector_area_entered", _on_objects_connector_area_entered)
	# warning-ignore:return_value_discarded
	element.connect("connector_area_exited", _on_objects_connector_area_exited)
	add_child(element)

	set_is_update_minimap_icons(true)

func show_sprite_icon(element: Element, connector: Connector):
	var icon: Texture2D = _wire_icon if _is_wire_selected_scene() else null

	if element.check_connect_to_wire(connector):
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

func sort_wires_for_representation():
	var children_top = get_children()

# TODO children_top.sort_custom(_sort_util._sort_by_rect_bottom_side)
	for i in range(children_top.size()):
		var child_top = children_top[i]
		var index = i
		if child_top.type == Globals.Elements.WIRE:
			index = 0
		move_child(child_top, index)

# selected scene

func get_selected_scene() -> PackedScene:
	return _selected_scene

func set_selected_scene(scene: PackedScene) -> void:
	_selected_scene = scene

func setup_selected_scene(scene: PackedScene, texture: Texture2D) -> void:
	# to hide wires over other elements
	sort_wires_for_representation()

	set_selected_scene(scene)
	clear_selected_elements()
	emit_signal(
		"sprite_texture_saved",
		texture,
		# save polygon data to check safe area
		scene.instantiate().get_node(^"SafeArea/CollisionShape2D").shape.size,
		# is_element (to use BW cursors)
		# becomes semi-transparent
		false if _is_wire_selected_scene() else true
	)

func reset_selected_scene() -> void:
	_selected_scene = null

func remove_selected_scene() -> void:
	# to hide wires over other elements
	sort_wires_for_representation()

	emit_signal("scene_deselected")
	reset_selected_scene()
	reset_active_wire()
	emit_signal("sprite_hided")
	emit_signal("sprite_texture_removed")

# camera

func get_actual_zoom() -> float:
	return _actual_zoom

# active wire

func get_active_wire() -> Element:
	return _active_wire

func set_active_wire(value: Element) -> void:
	_active_wire = value

func reset_active_wire() -> void:
	_active_wire = null

# Minimap

func is_minimap_entered() -> bool:
	return _is_minimap_entered

func set_minimap_disabled(value: bool) -> void:
	emit_signal("minimap_disabled", value)

func set_is_update_minimap_icons(value: bool) -> void:
	_minimap_util.set_is_update_minimap_icons(value)

# active connectors

func get_active_connector() -> Connector:
	if !_active_connectors.is_empty():
		return _active_connectors.values()[0]
	return null

func _add_active_connector(connector: Connector) -> void:
	_active_connectors[connector.get_instance_id()] = connector

func _remove_active_connector(connector: Connector):
	_active_connectors.erase(connector.get_instance_id())

# selected elements

func set_selected_elements_from_areas(selected_areas: Array) -> void:
	for area in selected_areas:
		var element = area.collider.owner
		# to protect from wrong placement
		element.last_valid_position = element.position
		if !selected_elements.has(element):
			add_selected_element(element)

func clear_selected_elements() -> void:
	get_tree().call_group_flags(
		SceneTree.GROUP_CALL_DEFAULT, "Elements", "outline", false
	)
	# to correctly reconect wires after cloning
	get_tree().call_group_flags(
		SceneTree.GROUP_CALL_DEFAULT, "Elements", "set_is_cloned", false
	)

	selected_elements.clear()

func update_selected_elements_last_valid_position():
	for element in selected_elements.values():
		element.last_valid_position = element.position

func re_add_selected_element(element: Element) -> void:
	element.last_valid_position = element.position
	if !is_selected_element(element):
		clear_selected_elements()
		add_selected_element(element)

func is_selected_element(element: Element) -> bool:
	return selected_elements.has(element.get_instance_id())

func add_selected_element(element: Element) -> void:
	var element_id = element.get_instance_id()
	# use element_id as key
	selected_elements[element_id] = element
	element.call_deferred("outline", true)

func remove_selected_element(element: Element) -> void:
	# warning-ignore:return_value_discarded
	selected_elements.erase(element.get_instance_id())
	element.call_deferred("outline", false)

# copy/paste
func copy_elements(elements: Array):
	_clone_util.set_last_saved_elements(elements
)
func paste_elements():
	clear_selected_elements()
	_clone_util.duplicate(
		self,
		_clone_util.get_last_saved_elements(),
		_clone_util.get_delta(get_global_mouse_position()),
	)

# states

func _is_create_state() -> bool:
	return (active_state == create_state)

func _is_drag_element_state() -> bool:
	return (active_state == drag_element_state)

func _is_drag_selected_state() -> bool:
	return (active_state == drag_selected_state)

func _is_wire_selected_scene() -> bool:
	return (_selected_scene == _wire_scene)

func _update_minimap() -> void:
	var is_update_icons = _minimap_util.is_update_minimap_icons()
	var is_update_frame = _minimap_util.is_update_minimap_frame()

	if is_update_icons:
		emit_signal("minimap_icons_updated", _minimap_util.get_minimap_icons())

	if is_update_icons || is_update_frame:
		# subviewport size
		var default_minimap_size: Vector2 = Vector2(get_viewport().size) / Globals.MINIMAP.SCALE
		var minimap_frame: Dictionary = _minimap_util.get_minimap_frame(
			default_minimap_size, _actual_zoom, _actual_offset
		)

		if minimap_frame.is_empty():
			emit_signal("minimap_reseted")
			return

		emit_signal(
			"minimap_frame_updated",
			default_minimap_size,
			minimap_frame.camera_zoom,
			minimap_frame.camera_offset,
			minimap_frame.frame,
			minimap_frame.marker,
			minimap_frame.rect
		)

func _on_viewport_size_changed():
	_minimap_util.set_is_update_minimap_frame(true)

func _on_file_menu_file_loaded() -> void:
	sort_wires_for_representation()

func _on_camera_2d_zoom_changed(value: float) -> void:
	_actual_zoom = value
	_minimap_util.set_is_update_minimap_frame(true)

func _on_camera_2d_offset_changed(offset: Vector2) -> void:
	_actual_offset = offset
	_minimap_util.set_is_update_minimap_frame(true)

func _on_minimap_menu_mouse_entered() -> void:
	_is_minimap_entered = true

func _on_minimap_menu_mouse_exited() -> void:
	_is_minimap_entered = false

func _on_element_menu_button_pressed(scene: PackedScene, icon: Texture2D, pressed: bool) -> void:
	if has_safe_area_entered_element():
		emit_signal("scene_deselected")
		return

	if pressed:
		active_state.process_setup_selected_scene(scene, icon)
	else:
		active_state.process_remove_selected_scene()

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
	var elements: Array = selected_elements.values()
	clear_selected_elements()
	_clone_util.duplicate(self, elements, Vector2(64, 64))

func _on_popup_tool_copy_pressed() -> void:
	copy_elements(selected_elements.values())

func _on_popup_tool_paste_pressed() -> void:
	paste_elements()

func _on_popup_tool_unlink_pressed() -> void:
	for element in selected_elements.values():
		element.call_deferred("unlink")

func _on_popup_tool_delete_pressed() -> void:
	for element in selected_elements.values():
		element.call_deferred("delete", true)

func _on_element_delete_processed(element: Element) -> void:
	remove_selected_element(element)

	for connector in element.get_connectors_children():
		_remove_active_connector(connector)

	for child in element.get_connectors_children():
		child.remove_connections_with_self()

	element.queue_free()

	element.clear_connectors_children()
	if is_ancestor_of(element):
		element.outline(false)
		remove_child(element)

	set_is_update_minimap_icons(true)

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
		element.remove_safe_area_entered(area)
		if element.is_safe_area_entered():
			return
		element.safe_area_alarm(false)

func _on_objects_connector_mouse_entered(
	element: Element, connector: Area2D
) -> void:

	_add_active_connector(connector)

	# prevent show when draw
	if _is_create_state():
		show_sprite_icon(element, connector)

func _on_objects_connector_mouse_exited(connector: Area2D) -> void:
	_remove_active_connector(connector)

	emit_signal("sprite_showed")

func _on_objects_connector_area_entered(
	connector: Connector, other: Connector
) -> void:

	if (
		connector.owner.type == Globals.Elements.WIRE
		&& other.owner.type == Globals.Elements.WIRE
	):
		# disable connection in selection mode
		if _is_drag_selected_state():
			return
#
		if !Connector.allowed_connection_to_wire(connector, other):
			return

		Connector.setup_connection(connector, connector.owner, other, other.owner)
	elif (
		connector.owner.type == Globals.Elements.WIRE
		|| other.owner.type == Globals.Elements.WIRE
	):

		# disable connection for drag selection and drag element
		if _is_drag_selected_state() || _is_drag_element_state():
			return

		if !Connector.allowed_connection_to_object(connector, other):
			return

		Connector.setup_connection(connector, connector.owner, other, other.owner)
	else:
		# disable auto-connection in selection mode
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
		wire.sync_wire_nodes(false)

		wire.call_deferred("show_sprites")
		# to correctly connect wire when draw
		wire.call_deferred("enable_first_connectors")

		# create reference to remove wires
		if connector.owner.is_mouse_entered():
			connector.owner.add_temporary_wire(wire)
		else:
			other.owner.add_temporary_wire(wire)

func _on_objects_connector_area_exited(
	connector: Connector, other: Connector
) -> void:

	# disable reset in drag element mode
	if _is_drag_element_state():
		return
	connector.remove_connections_with_elements()
	other.remove_connections_with_elements()
