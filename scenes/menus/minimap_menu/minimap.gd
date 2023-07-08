extends SubViewport

signal minimap_frame_moved

var origin: Vector2 = Vector2()

@onready var minimap_canvas: Node2D = $Canvas
@onready var minimap_camera: Camera2D = $Camera2D

func _ready() -> void:
	prints(name, "ready")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
			if event.button_index == MOUSE_BUTTON_LEFT:
				if get_visible_rect().has_point(event.position):
					_move_minimap_frame(event.position)

	if event is InputEventScreenDrag:
		if get_visible_rect().has_point(event.position):
			_move_minimap_frame(event.position)

func _move_minimap_frame(pos: Vector2) -> void:
	var diff = (origin + pos / minimap_camera.zoom) * Globals.MINIMAP.SCALE
	emit_signal("minimap_frame_moved", diff)

#func
#	if get_visible_rect().has_point(event.position):


func _on_elements_minimap_icons_updated(items: Array) -> void:
	minimap_canvas.icons = items

func _on_elements_minimap_frame_updated(
	viewport_size: Vector2,
	camera_zoom: Vector2,
	camera_offset: Vector2,
	minimap_frame: Rect2,
	minimap_marker: Rect2,
	minimap_rect: Rect2
) -> void:

	var is_marker_visible: bool = not(minimap_rect.intersects(minimap_frame, true))

	size = viewport_size
	minimap_camera.zoom = camera_zoom
	minimap_camera.offset = camera_offset
	minimap_canvas.frame = minimap_frame
	minimap_canvas.marker = minimap_marker
	minimap_canvas.is_marker_visible = is_marker_visible
	minimap_canvas.queue_redraw()

	origin = minimap_rect.position

func _on_elements_minimap_reseted() -> void:
	minimap_canvas.frame = Rect2()
	minimap_canvas.marker = Rect2()
	minimap_canvas.is_marker_visible = false
	minimap_canvas.queue_redraw()

func _on_elements_minimap_disabled(value: bool) -> void:
	gui_disable_input = value
