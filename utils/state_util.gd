extends Reference

class_name ObjectState

class State:
	var _machine: Node2D = null
	var _name: String = "State"

	func _init(machine: Node2D) -> void:
		_machine = machine

	func process_event(_event: InputEvent, _mouse_pos: Vector2) -> void:
		_show_warning("process_event")

	func process_set_selected_scene(_scene: PackedScene, _texture: Texture) -> void:
		_show_warning("process_set_selected_scene")

	func process_remove_selected_scene() -> void:
		_show_warning("process_remove_selected_scene")

	func draw():
		_show_warning("draw")

	func _show_warning(text: String) -> void:
		push_warning("Wrong state {cls}: {txt}".format({cls=_name, txt=text}))


class Idle:
	extends State

	func _init(machine: Node2D).(machine) -> void:
		_name = "Idle"

	func process_event(event: InputEvent, mouse_pos: Vector2) -> void:
		var entered_element = _machine.get_mouse_entered_element()
		if entered_element:
			var element_type = entered_element.type
			if event is InputEventMouseButton:
				if event.button_index == BUTTON_LEFT:
					if event.is_doubleclick():
						if element_type == Globals.Elements.WIRE:
							entered_element.unlink_wire()
					elif event.pressed:
						_left_button_pressed(element_type, entered_element)

				elif event.button_index == BUTTON_RIGHT:
					_right_button_clicked(entered_element)
		else:
			if event is InputEventMouseButton && event.pressed:
				_machine.remove_selected_elements()
				_machine.sort_objects_for_representation()
				_machine._select_start = mouse_pos

				_machine.set_state(_machine.select_state)

	func draw():
		# to prevent warning after switch from select_state
		pass

	func process_set_selected_scene(scene: PackedScene, texture: Texture) -> void:
		_machine.set_selected_scene(scene)
		_machine.remove_selected_elements()
		_machine.emit_signal(
			"sprite_texture_saved",
			texture,
			# save polygon data to check safe area
			scene.instance().get_node("SafeArea/CollisionShape2D").polygon
		)
		_machine.get_tree().call_group(
			"Elements", "set_alpha", Globals.GAME.UNSELECTED_ALPHA
		)

		_machine.set_state(_machine.create_state)

	func _left_button_pressed(element_type, entered_element: Element) -> void:
		if element_type == Globals.Elements.WIRE:
			_machine.move_child(
				entered_element, _machine.get_child_count() - 1
			)
		else:
			_machine.sort_objects_for_representation(true)
			_machine.move_child(
				entered_element, _machine.get_child_count() - 1
			)
			entered_element.move_wires_on_top()

		_machine.update_selected_elements_last_valid_position()
		_machine.re_add_selected_element(entered_element)

		if _machine.get_selected_elements().size() == 1:
			if element_type == Globals.Elements.WIRE:
				_machine.set_state(_machine.drag_wire_state)
			else:
				_machine.set_state(_machine.drag_element_state)
		else:
			_machine.set_state(_machine.drag_selected_state)

	func _right_button_clicked(entered_element: Element) -> void:
		_machine.emit_signal(
			"menu_poped",
			entered_element,
			_machine.get_selected_elements().size() > 1
		)

		_machine.update_selected_elements_last_valid_position()
		_machine.re_add_selected_element(entered_element)


class Create:
	extends State

	func _init(machine: Node2D).(machine) -> void:
		_name = "Create"

	func process_event(event: InputEvent, mouse_pos: Vector2) -> void:
		if event is InputEventMouseButton && event.pressed:
			if event.button_index == BUTTON_LEFT:
				var instance = _machine.get_selected_scene().instance()
				var entered_element = _machine.get_mouse_entered_element()

				if instance.type == Globals.Elements.WIRE:
					# instance only when mouse hover on the Connector
					if (
						entered_element
						&& entered_element.get_entered_connector()
					):
						_machine._wire = instance
						_machine.__add_child(instance)

						_machine.set_state(_machine.draw_wire_state)
				else:
					# prevent create
					if _machine.has_safe_area_entered_element():
						return

					instance.position = mouse_pos
					_machine.__add_child(instance)
					_machine.sort_objects_for_representation()

			elif event.button_index == BUTTON_RIGHT:
				process_remove_selected_scene()

	func process_remove_selected_scene() -> void:
		_machine.emit_signal("scene_deselected")
		_machine.remove_selected_scene()
		_machine.emit_signal("sprite_hided")
		_machine.emit_signal("sprite_texture_removed")
		_machine.get_tree().call_group("Elements", "set_alpha", 1.0)

		_machine.set_state(_machine.idle_state)


class DrawWire:
	extends State

	func _init(machine: Node2D).(machine) -> void:
		_name = "DrawWire"

	func process_event(event: InputEvent, mouse_pos: Vector2) -> void:
		if is_instance_valid(_machine._wire):
			if !_machine._wire.has_points():
				_machine._wire.add_points(mouse_pos)

			if event is InputEventScreenDrag:
				_machine._wire.start()
			elif event is InputEventMouseButton && !event.pressed:
				_machine._wire.delete_if_not_finished()

				var connector: Area2D =_machine._wire.get_entered_connector()
				if connector:
					_machine.show_sprite_icon(_machine._wire, connector)

				_machine._wire = null

				_machine.set_state(_machine.create_state)
		else:
			_machine.set_state(_machine.create_state)


class Select:
	extends State

	func _init(machine: Node2D).(machine) -> void:
		_name = "Select"

	func process_event(event: InputEvent, mouse_pos: Vector2) -> void:
		if event is InputEventScreenDrag:
			var _select_end = mouse_pos
			_machine._select_rect.extents = (_select_end - _machine._select_start) / 2

			var space = _machine.get_world_2d().direct_space_state

			var query = Physics2DShapeQueryParameters.new()
			query.collision_layer = 1
			query.collide_with_areas = true
			query.collide_with_bodies = false

			query.set_shape(_machine._select_rect)
			query.transform = Transform2D(0, (_select_end + _machine._select_start) / 2)

			_machine.remove_selected_elements()

			_machine.set_selected_elements_from_areas(
				space.intersect_shape(query, Globals.GAME.MAXIMUM_ELEMENTS_TO_SELECT)
			)
			_machine.update()

		elif event is InputEventMouseButton && !event.pressed:
			# _machine.update call _machine._draw func
			_machine.update()
			_machine.set_state(_machine.idle_state)
#
	func draw():
		_machine.draw_rect(
			Rect2(
				_machine._select_start,
				_machine.get_global_mouse_position() - _machine._select_start
			),
			Color(.5, .5, .5),
			false
		)


class DragWire:
	extends State

	func _init(machine: Node2D).(machine) -> void:
		_name = "DragWire"

	func _process_drag(elements: Array, _delta: Vector2, mouse_pos: Vector2) -> void:
		for element in elements:
			element.move_element(mouse_pos)

	func _process_safe_areas(element: Element):
		element.move_connected_wires()

	func _process_drag_end(elements: Array):
		for element in elements:
			if element.type == Globals.Elements.WIRE:
				element.switch_connections()
			else:
				element.clear_temporary_wires()

		_machine.set_state(_machine.idle_state)

	func process_event(event: InputEvent, mouse_pos: Vector2) -> void:
		var selected_elements = _machine.get_selected_elements().values()
		if event is InputEventScreenDrag:
			var delta = event.relative * _machine._actual_zoom
			_process_drag(selected_elements, delta, mouse_pos)

		elif event is InputEventMouseButton && !event.pressed:
			if _machine.has_safe_area_entered_element():
				for element in selected_elements:
					element.position = element.last_valid_position
					_process_safe_areas(element)

			_process_drag_end(selected_elements)


class DragElement:
	extends DragWire

	func _init(machine: Node2D).(machine) -> void:
		_name = "DragElement"

	func _process_drag(elements: Array, delta: Vector2, _mouse_pos: Vector2) -> void:
		for element in elements:
			element.move_element(delta)


class DragSelected:
	extends DragWire

	func _init(machine: Node2D).(machine) -> void:
		_name = "DragSelected"

	func _process_drag(elements: Array, delta: Vector2, _mouse_pos: Vector2) -> void:
		for element in elements:
			element.position += delta

	func _process_safe_areas(element: Element):
		element.restore_connected_wires()

	func _process_drag_end(_elements: Array):
		_machine.set_state(_machine.idle_state)




