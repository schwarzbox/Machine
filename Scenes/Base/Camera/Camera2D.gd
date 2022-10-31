extends Camera2D

var _zoom_in_shortcut: ShortCut = null
var _zoom_out_shortcut: ShortCut = null

var _drag_camera: bool = false
var _zoom_in: bool = false
var _zoom_out: bool = false

func _ready() -> void:
	self._zoom_in_shortcut = self._add_input_event(KEY_EQUAL)
	self._zoom_out_shortcut = self._add_input_event(KEY_MINUS)

	self.set_camera_in_center()

func set_camera_in_center() -> void:
	self.offset = self.get_viewport_rect().size / 2

func _add_input_event(key: int) -> ShortCut:
	var input_event = InputEventKey.new()
	input_event.scancode = key

	if Globals.OS_NAME == 'OSX':
		input_event.command = true
	else:
		input_event.control = true

	var shortcut = ShortCut.new()
	shortcut.set_shortcut(input_event)
	return shortcut

func _camera_zoom(factor: float) -> void:
	var zx = self.zoom.x * factor
	var zy = self.zoom.y * factor

	self.zoom = Vector2(
		clamp(zx, 1.0, Globals.CAMERA.ZOOM_MAX),
		clamp(zy, 1.0, Globals.CAMERA.ZOOM_MAX)
	)
	Globals.ACTUAL_ZOOM = self.zoom.x

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMagnifyGesture:
		self._camera_zoom(event.factor)

	if event is InputEventPanGesture:
		self.offset += event.delta * Globals.CAMERA.PAN_SPEED

	if event is InputEventKey:
		if _zoom_in_shortcut.is_shortcut(event):
			if event.pressed:
				self._zoom_in = true
			else:
				self._zoom_in = false

		if _zoom_out_shortcut.is_shortcut(event):
			if event.pressed:
				self._zoom_out = true
			else:
				self._zoom_out = false

		if event.scancode == KEY_SPACE:
			if event.pressed:
				self._drag_camera = true
			else:
				self._drag_camera = false

	if event is InputEventScreenDrag && self._drag_camera:
		self.offset -= event.relative * Globals.CAMERA.DRAG_SPEED

		self.get_tree().set_input_as_handled()

func _process(delta: float) -> void:
	if self._zoom_in:
		self._camera_zoom(1 - delta)
	if self._zoom_out:
		self._camera_zoom(1 + delta)

func _on_FileMenu_file_loaded() -> void:
	self.set_camera_in_center()
