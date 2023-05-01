extends Camera2D

signal zoom_changed

var _zoom_in_shortcut: Shortcut = null
var _zoom_out_shortcut: Shortcut = null

var _is_camera_dragged: bool = false
var _is_zoom_in: bool = false
var _is_zoom_out: bool = false

func _ready() -> void:
	_zoom_in_shortcut = _add_input_event(KEY_EQUAL)
	_zoom_out_shortcut = _add_input_event(KEY_MINUS)

	_set_camera_in_center()

func _process(delta: float) -> void:
	if _is_zoom_in:
		_camera_zoom(1 + delta)
	if _is_zoom_out:
		_camera_zoom(1 - delta)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMagnifyGesture:
		_camera_zoom(event.factor)

	if event is InputEventPanGesture:
		offset += event.delta * Globals.CAMERA.PAN_SPEED

	if event is InputEventKey:
		if _zoom_in_shortcut.matches_event(event):
			if event.pressed:
				_is_zoom_in = true
			else:
				_is_zoom_in = false

		if _zoom_out_shortcut.matches_event(event):
			if event.pressed:
				_is_zoom_out = true
			else:
				_is_zoom_out = false

		if event.keycode == KEY_SPACE:
			if event.pressed:
				_is_camera_dragged = true
			else:
				_is_camera_dragged = false

	if event is InputEventScreenDrag && _is_camera_dragged:
		offset -= event.relative * Globals.CAMERA.DRAG_SPEED

		get_viewport().set_input_as_handled()


func _add_input_event(key: int) -> Shortcut:
	var input_event = InputEventKey.new()
	input_event.keycode = key

	input_event.command_or_control_autoremap = true

	var shortcut = Shortcut.new()
	shortcut.set_events([input_event])

	return shortcut

func _set_camera_in_center() -> void:
	offset = get_viewport_rect().size / 2

func _camera_zoom(factor: float) -> void:
	zoom = Vector2(
		clamp(zoom.x * factor, Globals.CAMERA.ZOOM_MIN, Globals.CAMERA.ZOOM_MAX),
		clamp(zoom.y * factor, Globals.CAMERA.ZOOM_MIN, Globals.CAMERA.ZOOM_MAX)
	)
	emit_signal("zoom_changed", zoom.x)

func _on_file_menu_file_loaded() -> void:
	_set_camera_in_center()
