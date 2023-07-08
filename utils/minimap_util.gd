class_name MinimapUtil

extends RefCounted

var _minimap_icons: Array[Rect2] = []: get = get_minimap_icons
var _minimap_min_size = null
var _minimap_max_size = null
var _is_update_minimap_icons: bool = true:
	get = is_update_minimap_icons, set = set_is_update_minimap_icons
var _is_update_minimap_frame: bool = true:
	get = is_update_minimap_frame, set = set_is_update_minimap_frame


func get_minimap_icons() -> Array[Rect2]:
	return _minimap_icons

func set_minimap_icons(element: Element):
	if !_is_update_minimap_icons:
		return

	var top_left = element.position - element.minimap_half_element_size
	var bottom_right = element.position + element.minimap_half_element_size

	if _minimap_min_size == null || _minimap_max_size == null:
		_minimap_min_size = top_left
		_minimap_max_size = bottom_right

	if top_left.x < _minimap_min_size.x:
		_minimap_min_size.x = top_left.x
	if bottom_right.x > _minimap_max_size.x:
		_minimap_max_size.x = bottom_right.x

	if top_left.y < _minimap_min_size.y:
		_minimap_min_size.y = top_left.y
	if bottom_right.y > _minimap_max_size.y:
		_minimap_max_size.y = bottom_right.y

	if element.type != Globals.Elements.WIRE:
		_set_minimap_rectangle(
			top_left / Globals.MINIMAP.SCALE,
			element.minimap_element_size / Globals.MINIMAP.SCALE
		)

func reset_minimap_icons():
	if !_is_update_minimap_icons:
		return

	_minimap_min_size = null
	_minimap_max_size = null
	_minimap_icons.clear()

func get_minimap_frame(
	default_minimap_size: Vector2, actual_zoom: float, actual_offset: Vector2
) -> Dictionary:
	var frame_data: Dictionary = {}
	if _minimap_min_size && _minimap_max_size:
		var total_size: Vector2 = (_minimap_max_size - _minimap_min_size) / Globals.MINIMAP.SCALE
		var scaled_minimap: Vector2 = default_minimap_size / total_size
#
		var min_scale: float = min(scaled_minimap.x, scaled_minimap.y)

		if min_scale > actual_zoom - 0.01:
			min_scale = actual_zoom - 0.01

		# camera
		var minimap_center: Vector2 = total_size / 2 + _minimap_min_size / Globals.MINIMAP.SCALE
		frame_data["camera_zoom"] = Vector2(min_scale, min_scale)
		frame_data["camera_offset"] = minimap_center

		# frame
		var frame_size: Vector2 = default_minimap_size / actual_zoom
		var frame_half_size: Vector2 = frame_size / 2
		var frame_offset: Vector2 = actual_offset / Globals.MINIMAP.SCALE
		var fx: float = frame_offset.x - frame_half_size.x
		var fy: float = frame_offset.y - frame_half_size.y
		frame_data["frame"] = Rect2(fx, fy, frame_size.x, frame_size.y)

		# marker
		var minimap_size: Vector2 = default_minimap_size / min_scale
		var minimap_half_size: Vector2 = minimap_size / 2
		var top_left_minimap: Vector2 = minimap_center - minimap_half_size
		var bottom_right_minimap: Vector2 = minimap_center + minimap_half_size

		var marker_size: Vector2 = (
			Vector2(
				Globals.MINIMAP.MARKER_SIZE,
				Globals.MINIMAP.MARKER_SIZE / (default_minimap_size.x / default_minimap_size.y)
			)
			/ min_scale
		)
		var marker_half_size: Vector2 = marker_size / 2
		var mx: float = clamp(
			frame_offset.x - marker_half_size.x,
			top_left_minimap.x + 1,
			bottom_right_minimap.x - marker_size.x
		)
		var my: float = clamp(
			frame_offset.y - marker_half_size.y,
			top_left_minimap.y + 1,
			bottom_right_minimap.y - marker_size.y
		)
		frame_data["marker"] = Rect2(mx, my, marker_size.x, marker_size.y)
		frame_data["rect"] = Rect2(
			top_left_minimap.x, top_left_minimap.y, minimap_size.x, minimap_size.y
		)

		_is_update_minimap_icons = false
		_is_update_minimap_frame = false

	return frame_data

func is_update_minimap_frame() -> bool:
	return _is_update_minimap_frame

func set_is_update_minimap_frame(value: bool) -> void:
	_is_update_minimap_frame = value

func is_update_minimap_icons() -> bool:
	return _is_update_minimap_icons

func set_is_update_minimap_icons(value: bool) -> void:
	_is_update_minimap_icons = value

func _set_minimap_rectangle(top_left: Vector2, element_size: Vector2):
	_minimap_icons.append(
		Rect2(
			top_left.x, top_left.y, element_size.x, element_size.y
		)
	)
