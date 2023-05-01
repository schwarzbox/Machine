class_name ObjectState

extends RefCounted

class State:
	var _machine: Node2D = null
	var _name: String = "State"

	func _init(machine: Node2D):
		_machine = machine

	func _warp_mouse(mouse_pos: Vector2):
		var viewport = _machine.get_viewport()
		viewport.warp_mouse(
			mouse_pos *  _machine.actual_zoom + viewport.canvas_transform.origin
		)

	func process_event(_event: InputEvent, _mouse_pos: Vector2) -> void:
		_show_warning("process_event")

	func process_set_selected_scene(_scene: PackedScene, _texture: Texture2D) -> void:
		_show_warning("process_set_selected_scene")

	func process_remove_selected_scene() -> void:
		_show_warning("process_remove_selected_scene")

	func draw():
		_show_warning("draw")

	func _show_warning(txt: String) -> void:
		push_warning("Wrong state {cls}: {txt}".format({cls=_name, txt=txt}))

class Idle:
	extends State

	func _init(machine: Node2D):
		super(machine)
		_name = "Idle"

	func process_set_selected_scene(scene: PackedScene, texture: Texture2D) -> void:
		_machine.set_selected_scene(scene, texture)

		_machine.active_state = _machine.create_state

	func process_event(event: InputEvent, mouse_pos: Vector2) -> void:

		if event is InputEventKey:
			var elements = _machine.selected_elements.values()
			if elements.size() == 1:
				_rotate_with_arrows(elements[0])

		var entered_element = _machine.get_mouse_entered_element()
		# fix popup tool behaviour after hide
		if (
			entered_element
			&& entered_element.is_mouse_intersect_with_shape(mouse_pos)
		):

			_machine.emit_signal("cursor_shape_updated", Input.CURSOR_CAN_DROP)

			if entered_element.is_cloned:
				# to correctly reconect wires after cloning
				_machine.get_tree().call_group_flags(
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
					_right_button_clicked(entered_element)

		else:
			_machine.emit_signal("cursor_shape_updated", Input.CURSOR_ARROW)

			if event is InputEventMouseButton && event.pressed:
				# prevent put element in safe area
				if _machine.has_safe_area_entered_element():
					return

				if event.button_index == MOUSE_BUTTON_LEFT:
					_machine.emit_signal("cursor_shape_updated", Input.CURSOR_CROSS)
					_machine.remove_selected_elements()
					# sort when no entered element
					_machine.sort_objects_for_representation()
					_machine.selection_start = mouse_pos
					_machine.active_state = _machine.select_state

	func draw():
		# to prevent warning after switch from select_state
		pass

	func _rotate_with_arrows(element: Element) -> void:
		if Input.is_action_pressed("ui_left"):
			element.rotate_ccw()
		elif Input.is_action_pressed("ui_right"):
			element.rotate_cw()

	func _left_button_pressed(element_type, entered_element: Element) -> void:
		if element_type == Globals.Elements.WIRE:
			_machine.move_child(
				entered_element, _machine.get_child_count() - 1
			)
		else:
			# sort before select enetered element
			_machine.sort_objects_for_representation()
			_machine.move_child(
				entered_element, _machine.get_child_count() - 1
			)
			entered_element.move_wires_on_top()

		_machine.update_selected_elements_last_valid_position()
		_machine.re_add_selected_element(entered_element)

		_machine.emit_signal("cursor_shape_updated", Input.CURSOR_DRAG)

		if _machine.selected_elements.size() == 1:
			if element_type == Globals.Elements.WIRE:
				_machine.active_state = _machine.drag_wire_state
			else:
				_machine.active_state = _machine.drag_element_state
		else:
			_machine.active_state = _machine.drag_selected_state

	func _right_button_clicked(entered_element: Element) -> void:
		_machine.emit_signal(
			"menu_poped",
			entered_element,
			_machine.selected_elements.size() > 1
		)
		_machine.emit_signal("cursor_shape_updated", Input.CURSOR_ARROW)

		_machine.update_selected_elements_last_valid_position()
		_machine.re_add_selected_element(entered_element)

class Create:
	extends State

	func _init(machine: Node2D):
		super(machine)
		_name = "Create"

	func process_set_selected_scene(scene: PackedScene, texture: Texture2D) -> void:
		_machine.set_selected_scene(scene, texture)

	func process_remove_selected_scene() -> void:
		_machine.remove_selected_scene()

		_machine.active_state = _machine.idle_state

	func process_event(event: InputEvent, mouse_pos: Vector2) -> void:
		if event is InputEventMouseButton && event.pressed:
			if event.button_index == MOUSE_BUTTON_LEFT:
				var instance = _machine.selected_scene.instantiate()
				var entered_element = _machine.get_mouse_entered_element()

				if instance.type == Globals.Elements.WIRE:
					# instance only when mouse hover checked the Connector
					if entered_element:
						var entered_connector = entered_element.get_entered_connector()
						if entered_element.get_entered_connector():
							# prevent create wire when not allowed
							if !entered_element.check_connect_to_wire(entered_connector):
								return

						_machine.active_wire = instance
						_machine.add_child_element(instance)

						instance.position = mouse_pos
						_machine.active_state = _machine.draw_wire_state
				else:
					# prevent put element in safe area
					if _machine.has_safe_area_entered_element():
						return

					instance.position = mouse_pos
					_machine.add_child_element(instance)

					# sort after create element
#					_machine.sort_objects_for_representation()

			elif event.button_index == MOUSE_BUTTON_RIGHT:
				process_remove_selected_scene()

class DrawWire:
	extends State

	var direction: Globals.Directions = Globals.Directions.NONE

	func _init(machine: Node2D):
		super(machine)
		_name = "DrawWire"

	func process_event(event: InputEvent, mouse_pos: Vector2) -> void:
		if is_instance_valid(_machine.active_wire):
			if !Input.is_action_pressed("ui_shift"):
				direction = Globals.Directions.NONE

			var has_points = _machine.active_wire.has_points()
			if !has_points:
				_machine.active_wire.add_points(mouse_pos)

			if event is InputEventScreenDrag:
				# straight lines
				if Input.is_action_pressed("ui_shift"):
					if has_points:
						var points = _machine.active_wire.get_points()
						var sub_x = abs(points[0].x - points[1].x)
						var sub_y = abs(points[0].y - points[1].y)
						if sub_x > sub_y:
							direction = Globals.Directions.HORIZONTAL
						elif sub_x < sub_y:
							direction = Globals.Directions.VERTICAL

				_machine.active_wire.start_drawing(mouse_pos, direction)

			elif event is InputEventMouseButton && !event.pressed:
				_machine.active_wire.finish_drawing()

				# show icon after create wire
				var connector: Connector =_machine.active_wire.get_entered_connector()
				if connector:
					_machine.show_sprite_icon(_machine.active_wire, connector)

				_machine.active_wire = null

				# sort after create wire to hide path
				_machine.sort_objects_for_representation()
				_machine.active_state = _machine.create_state
		else:
			_machine.active_state = _machine.create_state

class Select:
	extends State

	func _init(machine: Node2D):
		super(machine)
		_name = "Select"

	func process_event(event: InputEvent, mouse_pos: Vector2) -> void:
		if event is InputEventScreenDrag:
			_machine.selection_rectangle.extents = abs(
				mouse_pos - _machine.selection_start
			) / 2

			var space = _machine.get_world_2d().direct_space_state

			var query = PhysicsShapeQueryParameters2D.new()
			query.collision_mask = 1
			query.collide_with_areas = true
			query.collide_with_bodies = false

			query.set_shape(_machine.selection_rectangle)
			query.transform = Transform2D(
				0, (mouse_pos + _machine.selection_start) / 2
			)

			_machine.remove_selected_elements()

			_machine.set_selected_elements_from_areas(
				space.intersect_shape(query,
				Globals.GAME.MAXIMUM_ELEMENTS_TO_SELECT)
			)
			_machine.queue_redraw()

		elif event is InputEventMouseButton && !event.pressed:
			# _machine.queue_redraw call _machine._draw func
			_machine.queue_redraw()

			_machine.emit_signal("cursor_shape_updated", Input.CURSOR_ARROW)

			_machine.active_state = _machine.idle_state
#
	func draw():
		_machine.draw_rect(
			Rect2(
				_machine.selection_start,
				_machine.get_global_mouse_position() - _machine.selection_start
			),
			Color(.5, .5, .5),
			false
		)

class DragWire:
	extends State

	func _init(machine: Node2D):
		super(machine)
		_name = "DragWire"

	func process_event(event: InputEvent, mouse_pos: Vector2) -> void:
		var selected_elements = _machine.selected_elements.values()

		if event is InputEventScreenDrag:
			var delta = event.relative / _machine.actual_zoom
			_process_drag(selected_elements, delta, mouse_pos)

		elif event is InputEventMouseButton && !event.pressed:
			# prevent put element in safe area
			if _machine.has_safe_area_entered_element():
				for element in selected_elements:
					element.position = element.last_valid_position
					_process_safe_areas(element)

			_process_drag_end(selected_elements)

	func _process_drag(elements: Array, _delta: Vector2, mouse_pos: Vector2) -> void:
		for element in elements:
			element.move_element(mouse_pos)

	func _process_safe_areas(element: Element):
		element.move_connected_wires()

	func _process_drag_end(elements: Array):
		for element in elements:
			element.sync_wire_nodes()

		_machine.emit_signal("cursor_shape_updated", Input.CURSOR_CAN_DROP)
		_machine.active_state = _machine.idle_state

class DragElement:
	extends DragWire

	func _init(machine: Node2D):
		super(machine)
		_name = "DragElement"

	func _process_drag(elements: Array, delta: Vector2, _mouse_pos: Vector2) -> void:
		for element in elements:
			element.move_element(delta)

	func _process_drag_end(elements: Array):
		for element in elements:
			element.clear_temporary_wires()

		_machine.emit_signal("cursor_shape_updated", Input.CURSOR_CAN_DROP)
		_machine.active_state = _machine.idle_state

class DragSelected:
	extends DragWire

	func _init(machine: Node2D):
		super(machine)
		_name = "DragSelected"

	func _process_drag(elements: Array, delta: Vector2, _mouse_pos: Vector2) -> void:
		for element in elements:
			element.position += delta

	func _process_safe_areas(element: Element):
		element.restore_connected_wires()

	func _process_drag_end(_elements: Array):
		_machine.emit_signal("cursor_shape_updated", Input.CURSOR_CAN_DROP)

		_machine.active_state = _machine.idle_state
