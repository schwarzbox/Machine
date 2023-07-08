extends Camera2D

signal cursor_shape_updated
signal zoom_changed
signal offset_changed

# TODO
#var _zoom_in_shortcut: Shortcut = null
#var _zoom_out_shortcut: Shortcut = null

var _is_camera_dragged: bool = false
var _is_zoom_in: bool = false
var _is_zoom_out: bool = false

func _ready() -> void:
	# TODO
#	_zoom_in_shortcut = _add_input_event(KEY_EQUAL)
#	_zoom_out_shortcut = _add_input_event(KEY_MINUS)

	_set_camera_in_center()

	emit_signal("zoom_changed", zoom.x)
	emit_signal("offset_changed", offset)


func _process(delta: float) -> void:
	if _is_zoom_in:
		_update_camera_zoom(1 + delta)
	if _is_zoom_out:
		_update_camera_zoom(1 - delta)

func _unhandled_input(event: InputEvent) -> void:

	if event is InputEventMagnifyGesture:
		_update_camera_zoom(event.factor)

	if event is InputEventPanGesture:
		_update_camera_offset(event.delta * Globals.CAMERA.PAN_SPEED)

	if Input.is_action_pressed("ui_zoom_in"):
		_is_zoom_in = true
	elif Input.is_action_just_released("ui_zoom_in"):
		_is_zoom_in = false
#
	if Input.is_action_pressed("ui_zoom_out"):
		_is_zoom_out = true
	elif Input.is_action_just_released("ui_zoom_out"):
		_is_zoom_out = false

	if event is InputEventKey:
		# TODO
#		if _zoom_in_shortcut.matches_event(event):
#			if event.pressed:
#				_is_zoom_in = true
#			else:
#				_is_zoom_in = false
#		if _zoom_out_shortcut.matches_event(event):
#			if event.pressed:
#				_is_zoom_out = true
#			else:
#				_is_zoom_out = false
		if event.keycode == KEY_SPACE:
			if event.pressed:
				_is_camera_dragged = true
			else:
				_is_camera_dragged = false

	if _is_camera_dragged:
		if event is InputEventMouseButton:
			if event.pressed:
				emit_signal("cursor_shape_updated", Input.CURSOR_DRAG)
			else:
				emit_signal("cursor_shape_updated", Input.CURSOR_CAN_DROP)

		if event is InputEventScreenDrag:
			_update_camera_offset(-1 * event.relative * Globals.CAMERA.DRAG_SPEED)

		# prevent selection mode
		get_viewport().set_input_as_handled()

# TODO
#func _add_input_event(key: int) -> Shortcut:
#	var input_event = InputEventKey.new()
#	input_event.keycode = key
#
#	input_event.command_or_control_autoremap = true
#
#	var shortcut = Shortcut.new()
#	shortcut.set_events([input_event])
#
#	return shortcut

func _set_camera_in_center() -> void:
	offset = get_viewport_rect().size / 2

func _update_camera_zoom(factor: float) -> void:
	zoom = Vector2(
		clamp(zoom.x * factor, Globals.CAMERA.ZOOM_MIN, Globals.CAMERA.ZOOM_MAX),
		clamp(zoom.y * factor, Globals.CAMERA.ZOOM_MIN, Globals.CAMERA.ZOOM_MAX)
	)
	emit_signal("zoom_changed", zoom.x)

func _update_camera_offset(factor: Vector2) -> void:
	offset += factor
	emit_signal("offset_changed", offset)

func _on_file_menu_file_loaded() -> void:
	_set_camera_in_center()

func _on_minimap_minimap_frame_moved(pos: Vector2) -> void:
	offset = pos
	emit_signal("offset_changed", offset)
