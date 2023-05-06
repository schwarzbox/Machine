class_name PopupTools

extends PopupMenu

# Elements
signal clone_pressed
signal delete_pressed
signal rotate_cw_pressed
signal rotate_ccw_pressed
signal unlink_pressed

enum PopupIds {
	HEADER,
	SEPARATOR,
	ROTATE_CW,
	ROTATE_CCW,
	CLONE,
	UNLINK,
	DELETE
}

var _element: Element = null
var _is_group: bool = false

func _ready() -> void:
	add_theme_font_size_override(
		"font_size", Globals.FONTS.DEFAULT_FONT_SIZE
	)
	add_theme_font_size_override(
		"font_separator_size", Globals.FONTS.DEFAULT_FONT_SIZE
	)

func _on_id_pressed(id: int) -> void:
	if !_element:
		return

	match id:
		PopupIds.ROTATE_CW:
			emit_signal("rotate_cw_pressed")
		PopupIds.ROTATE_CCW:
			emit_signal("rotate_ccw_pressed")
		PopupIds.CLONE:
			emit_signal("clone_pressed")
		PopupIds.UNLINK:
			emit_signal("unlink_pressed")
		PopupIds.DELETE:
			emit_signal("delete_pressed")

	_is_group = false
	_element = null

func _on_about_to_popup() -> void:
	if _element:
		add_separator("", PopupIds.HEADER)
		add_separator("", PopupIds.SEPARATOR)

		if _is_group:
			set_item_text(PopupIds.HEADER, "Group")
		else:
			set_item_text(PopupIds.HEADER, _element.type_name)

			if _element.type != Globals.Elements.WIRE:
				add_item("Rotate Left", PopupIds.ROTATE_CCW)
				add_item("Rotate Right", PopupIds.ROTATE_CW)

		add_item("Clone", PopupIds.CLONE)
		add_item("Unlink", PopupIds.UNLINK)
		add_item("Delete", PopupIds.DELETE)

func _on_elements_menu_poped(
	element: Element, viewport_height: int, is_group: bool = false
) -> void:
	_is_group = is_group
	_element = element
	if _element:
		clear()

		size = min_size
		popup(Rect2(0, 0, size.x, size.y))
		position = get_mouse_position()
		# add offset if out of the screen
		if (position.y + size.y) > viewport_height:
			position.y =  position.y - size.y

	else:
		_is_group = false
		_element = null
