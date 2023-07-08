class_name ObjectState

extends RefCounted

class State:
	var _main: Node2D = null
	var _name: String = "State"
	var _align_direction: Globals.Directions = Globals.Directions.NONE
	var _is_shift_pressed: bool = true
	var _is_command_pressed: bool = true

	func _init(main: Node2D):
		_main = main

	func process_event(_event: InputEvent, _mouse_pos: Vector2) -> void:
		_show_warning("process_event")

	func process_setup_selected_scene(_scene: PackedScene, _texture: Texture2D) -> void:
		_show_warning("process_setup_selected_scene")

	func process_remove_selected_scene() -> void:
		_show_warning("process_remove_selected_scene")

	func draw():
		_show_warning("draw")

	func _warp_mouse(mouse_pos: Vector2):
		var viewport = _main.get_viewport()
		viewport.warp_mouse(
			mouse_pos *  _main.get_actual_zoom() + viewport.canvas_transform.origin
		)

	func _shift_input() -> void:
		if Input.is_action_pressed("ui_shift"):
			_is_shift_pressed = true
		else:
			_is_shift_pressed = false
			_align_direction = Globals.Directions.NONE

	func _command_input() -> void:
		if Input.is_action_pressed("ui_command"):
			_is_command_pressed = true
		else:
			_is_command_pressed = false

	func _get_align_wire(
		wire: Element, mouse_pos: Vector2, point_index: int
	) -> Vector2:
		var points = wire.get_points()
		var sub_x = abs(points[0].x - points[1].x)
		var sub_y = abs(points[0].y - points[1].y)
		if sub_x > sub_y:
			_align_direction = Globals.Directions.HORIZONTAL
		elif sub_x < sub_y:
			_align_direction = Globals.Directions.VERTICAL

		return wire.align_wire(
			mouse_pos,
			wire.get_node(^"Line2D").points[point_index],
			_align_direction
		)

	func _show_warning(txt: String) -> void:
		push_warning("Wrong state {cls}: {txt}".format({cls = _name, txt = txt}))


class Idle:
	extends State

	func _init(main: Node2D):
		super(main)
		_name = "Idle"

	func process_setup_selected_scene(scene: PackedScene, texture: Texture2D) -> void:
		_main.setup_selected_scene(scene, texture)

		_main.active_state = _main.create_state

	func process_event(event: InputEvent, mouse_pos: Vector2) -> void:
		# allow drag minimap
		_main.set_minimap_disabled(false)

		# prevent events when use minimap
		if _main.is_minimap_entered():
			return

		if event is InputEventKey:

			# prevent put element in safe area
			if _main.has_safe_area_entered_element():
				return
			var elements: Array = _main.selected_elements.values()
			_copy_paste_with_keys(elements)
			if elements.size() == 1:
				_rotate_with_arrows(elements[0])

		# fix popup tool behaviour after hide
		var entered_element = _main.get_mouse_entered_element()
		if (
			entered_element
			&& entered_element.is_mouse_intersect_with_shape(mouse_pos)
		):
			# prevent put element in safe area
			if (
				!_main.is_selected_element(entered_element)
				&& _main.has_safe_area_entered_element()
			):
				return

			_main.emit_signal("cursor_shape_updated", Input.CURSOR_CAN_DROP)

			if entered_element.is_cloned:
				# to correctly reconect wires after cloning
				_main.get_tree().call_group_flags(
					SceneTree.GROUP_CALL_DEFAULT, "Elements", "set_is_cloned", false
				)

			var element_type = entered_element.type
			if event is InputEventMouseButton:
				if event.button_index == MOUSE_BUTTON_LEFT:
					if event.is_double_click():
						if element_type == Globals.Elements.WIRE:
							entered_element.unlink_wire()
						elif element_type == Globals.Elements.SWITCH:
							entered_element.switch()
						elif element_type == Globals.Elements.BUTTON:
							entered_element.switch()

					elif event.pressed:
						_left_button_pressed(element_type, entered_element)

				elif event.button_index == MOUSE_BUTTON_RIGHT:
					if event.pressed:
						_right_button_clicked(entered_element)

		else:
			_main.emit_signal("cursor_shape_updated", Input.CURSOR_ARROW)

			if event is InputEventMouseButton && event.pressed:
#				# prevent put element in safe area
				if _main.has_safe_area_entered_element():
					return

				if event.button_index == MOUSE_BUTTON_LEFT:
					_main.emit_signal("cursor_shape_updated", Input.CURSOR_CROSS)
					_main.clear_selected_elements()
					# sort when no entered element
					_main.sort_wires_for_representation()
					_main.selection_start = mouse_pos
					_main.active_state = _main.select_state

				elif event.button_index == MOUSE_BUTTON_RIGHT:
					_right_button_clicked()

	func draw():
		# to prevent warning after switch from select_state
		pass

	func _rotate_with_arrows(element: Element) -> void:
		if Input.is_action_pressed("ui_left"):
			element.rotate_ccw()
		elif Input.is_action_pressed("ui_right"):
			element.rotate_cw()

	func _copy_paste_with_keys(elements: Array) -> void:
		if Input.is_action_pressed("ui_copy"):
			_main.copy_elements(elements)
		elif Input.is_action_pressed("ui_paste"):
			_main.paste_elements()

	func _left_button_pressed(element_type, entered_element: Element) -> void:
		# prevent sorting
		if !_main.has_safe_area_entered_element():
			# sort before select enetered element
			_main.sort_wires_for_representation()

			_main.move_child(
				entered_element, _main.get_child_count() - 1
			)
#			Don't sort wires?
			entered_element.move_wires_on_top()

			# select/deselect with command
			_command_input()
			if _is_command_pressed:
				if _main.is_selected_element(entered_element):
					_main.remove_selected_element(entered_element)
				else:
					_main.add_selected_element(entered_element)
				return

		# update previously selected elements
		_main.update_selected_elements_last_valid_position()
		_main.re_add_selected_element(entered_element)

		_main.emit_signal("cursor_shape_updated", Input.CURSOR_DRAG)

		if _main.selected_elements.size() == 1:
			if element_type == Globals.Elements.WIRE:
				_main.active_state = _main.drag_wire_state
			else:
				_main.active_state = _main.drag_element_state
#				entered_element.call_deferred("reset_scale", Vector2(1.1, 1.1))
		else:
			_main.active_state = _main.drag_selected_state

	func _right_button_clicked(entered_element: Element = null) -> void:
		_main.emit_signal(
			"menu_poped",
			entered_element,
			_main.get_viewport_rect().size.y,
			_main.selected_elements.size() > 1,
		)
		_main.emit_signal("cursor_shape_updated", Input.CURSOR_ARROW)

		if entered_element:
			# update previously selected elements
			_main.update_selected_elements_last_valid_position()
			_main.re_add_selected_element(entered_element)


class Create:
	extends State

	func _init(main: Node2D):
		super(main)
		_name = "Create"

	func process_setup_selected_scene(scene: PackedScene, texture: Texture2D) -> void:
		# to switch one element to another in the create state
		_main.setup_selected_scene(scene, texture)

	func process_remove_selected_scene() -> void:
		_main.remove_selected_scene()
		_main.active_state = _main.idle_state

	func process_event(event: InputEvent, mouse_pos: Vector2) -> void:
		# prevent drag minimap
		_main.set_minimap_disabled(true)

		if event is InputEventMouseButton && event.pressed:
			if event.button_index == MOUSE_BUTTON_LEFT:
				var instance = _main.get_selected_scene().instantiate()

				if instance.type == Globals.Elements.WIRE:
					# instance only when mouse hover a Connector
					var main_active_connector = _main.get_active_connector()
					if main_active_connector:
						var entered_element = main_active_connector.owner
						# prevent create wire when not allowed
						if !entered_element.check_connect_to_wire(main_active_connector):
							return

						_main.set_active_wire(instance)
						_main.add_child_element(instance)

						instance.position = mouse_pos
						_main.active_state = _main.draw_wire_state
				else:
					# prevent put element in safe area
					if _main.has_safe_area_entered_element():
						return

					instance.position = mouse_pos
					_main.add_child_element(instance)

			elif event.button_index == MOUSE_BUTTON_RIGHT:
				if event.pressed:
					process_remove_selected_scene()
					# prevent pop-up
					_main.get_viewport().set_input_as_handled()

class DrawWire:
	extends State

	func _init(main: Node2D):
		super(main)
		_name = "DrawWire"

	func process_event(event: InputEvent, mouse_pos: Vector2) -> void:
		# prevent drag minimap
		_main.set_minimap_disabled(true)

		var main_active_wire = _main.get_active_wire()
		if is_instance_valid(main_active_wire):
			_shift_input()

			var has_points = main_active_wire.has_points()
			if !has_points:
				main_active_wire.add_points(mouse_pos)

			if event is InputEventScreenDrag:
				# straight lines
				if _is_shift_pressed && has_points:
					mouse_pos = _get_align_wire(
						main_active_wire, mouse_pos, 1
					)
					_warp_mouse(mouse_pos)

				main_active_wire.start_drawing(mouse_pos)

				_main.set_is_update_minimap_icons(true)

			elif event is InputEventMouseButton && !event.pressed:
				main_active_wire.finish_drawing()

				# show icon after create wire
				var main_active_connector: Connector = _main.get_active_connector()
				if main_active_connector:
					_main.show_sprite_icon(main_active_wire, main_active_connector)

				_main.reset_active_wire()

				_main.active_state = _main.create_state
		else:
			_main.active_state = _main.create_state

class Select:
	extends State

	func _init(main: Node2D):
		super(main)
		_name = "Select"

	func process_event(event: InputEvent, mouse_pos: Vector2) -> void:
		# prevent drag minimap
		_main.set_minimap_disabled(true)

		if event is InputEventScreenDrag:
			_main.selection_rectangle.extents = abs(
				mouse_pos - _main.selection_start
			) / 2

			var space = _main.get_world_2d().direct_space_state

			var query = PhysicsShapeQueryParameters2D.new()
			query.collision_mask = 1
			query.collide_with_areas = true
			query.collide_with_bodies = false

			query.set_shape(_main.selection_rectangle)
			query.transform = Transform2D(
				0, (mouse_pos + _main.selection_start) / 2
			)

			_main.clear_selected_elements()

			_main.set_selected_elements_from_areas(
				space.intersect_shape(query,
				Globals.GAME.MAXIMUM_ELEMENTS_TO_SELECT)
			)
			_main.queue_redraw()

		elif event is InputEventMouseButton && !event.pressed:
			# _main.queue_redraw call _main._draw func
			_main.queue_redraw()

			_main.emit_signal("cursor_shape_updated", Input.CURSOR_ARROW)

			_main.active_state = _main.idle_state
#
	func draw():
		_main.draw_rect(
			Rect2(
				_main.selection_start,
				_main.get_global_mouse_position() - _main.selection_start
			),
			Color(.5, .5, .5),
			false
		)

class DragWire:
	extends State

	func _init(main: Node2D):
		super(main)
		_name = "DragWire"

	func process_event(event: InputEvent, mouse_pos: Vector2) -> void:
		# prevent drag minimap
		_main.set_minimap_disabled(true)

		_shift_input()

		var selected_elements = _main.selected_elements.values()

		if event is InputEventScreenDrag:
			var delta = event.relative / _main.get_actual_zoom()
			_process_drag(selected_elements, delta, mouse_pos)

			_main.set_is_update_minimap_icons(true)

		elif event is InputEventMouseButton && !event.pressed:
			pass
			# prevent put element in safe area
			if _main.has_safe_area_entered_element():
				for element in selected_elements:
					element.position = element.last_valid_position
					_process_safe_areas(element)

			_process_drag_end(selected_elements)

	func _process_drag(elements: Array, _delta: Vector2, mouse_pos: Vector2) -> void:
		var main_active_connector = _main.get_active_connector()
		for element in elements:
			# straight lines
			if _is_shift_pressed:

				var point_index = 1
				if main_active_connector:
					if main_active_connector.name in ["In2", "Out2"]:
						point_index = 0

				mouse_pos = _get_align_wire(
					element, mouse_pos, point_index
				)
				_warp_mouse(mouse_pos)

			element.move_element(mouse_pos)

	func _process_safe_areas(element: Element):
		element.move_connected_wires()

	func _process_drag_end(elements: Array):
		for element in elements:
			element.sync_wire_nodes()

		_main.emit_signal("cursor_shape_updated", Input.CURSOR_CAN_DROP)
		_main.active_state = _main.idle_state

class DragElement:
	extends DragWire

	func _init(main: Node2D):
		super(main)
		_name = "DragElement"

	func _process_drag(elements: Array, delta: Vector2, _mouse_pos: Vector2) -> void:
		for element in elements:
			element.move_element(delta)

	func _process_drag_end(elements: Array):
		for element in elements:
			element.clear_temporary_wires()
			# TODO
#			element.reset_scale()

		_main.emit_signal("cursor_shape_updated", Input.CURSOR_CAN_DROP)
		_main.active_state = _main.idle_state

class DragSelected:
	extends DragWire

	func _init(main: Node2D):
		super(main)
		_name = "DragSelected"

	func _process_drag(elements: Array, delta: Vector2, _mouse_pos: Vector2) -> void:
		for element in elements:
			element.position += delta

	func _process_safe_areas(element: Element):
		element.restore_connected_wires()

	func _process_drag_end(_elements: Array):
		_main.emit_signal("cursor_shape_updated", Input.CURSOR_CAN_DROP)

		_main.active_state = _main.idle_state
