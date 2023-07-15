class_name PopupTools

extends PopupMenu

# Elements
signal rotate_cw_pressed
signal rotate_ccw_pressed
signal clone_pressed
signal copy_pressed
signal paste_pressed
signal unlink_pressed
signal delete_pressed

enum PopupIds {
	HEADER,
	SEPARATOR,
	ROTATE_CW,
	ROTATE_CCW,
	COPY,
	PASTE,
	CLONE,
	UNLINK,
	DELETE
}

var _defaul_width: int = 320
var _element: Element = null
var _is_group: bool = false
var _is_paste: bool = true

func _ready() -> void:
	add_theme_font_size_override(
		"font_size", Globals.FONTS.DEFAULT_FONT_SIZE
	)
	add_theme_font_size_override(
		"font_separator_size", Globals.FONTS.DEFAULT_FONT_SIZE
	)

func _reset() -> void:
	_element = null
	_is_group = false
	_is_paste = true

func _on_id_pressed(id: int) -> void:

	match id:
		PopupIds.ROTATE_CW:
			emit_signal("rotate_cw_pressed")
		PopupIds.ROTATE_CCW:
			emit_signal("rotate_ccw_pressed")
		PopupIds.CLONE:
			emit_signal("clone_pressed")
		PopupIds.COPY:
			emit_signal("copy_pressed")
		PopupIds.PASTE:
			emit_signal("paste_pressed")
		PopupIds.UNLINK:
			emit_signal("unlink_pressed")
		PopupIds.DELETE:
			emit_signal("delete_pressed")

	_reset()

func _on_about_to_popup() -> void:
	add_separator("Empty", PopupIds.HEADER)
	add_separator("", PopupIds.SEPARATOR)
	if _element:
		# prevent put element in safe area
		var is_safe_area_entered = _element.is_safe_area_entered()
		if _is_group:
			set_item_text(PopupIds.HEADER, "Group")
		else:
			set_item_text(PopupIds.HEADER, _element.type_name)

			if _element.type != Globals.Elements.WIRE:

				if !is_safe_area_entered:
					add_item("Rotate Left", PopupIds.ROTATE_CCW, KEY_LEFT)
					add_item("Rotate Right", PopupIds.ROTATE_CW, KEY_RIGHT)

		if !is_safe_area_entered:
			add_item("Copy", PopupIds.COPY, (KEY_MASK_CMD_OR_CTRL | KEY_C))
			add_item("Paste", PopupIds.PASTE, (KEY_MASK_CMD_OR_CTRL | KEY_V))
			add_separator("", PopupIds.SEPARATOR)
			add_item("Clone", PopupIds.CLONE)
			add_item("Unlink", PopupIds.UNLINK)
			add_separator("", PopupIds.SEPARATOR)

		add_item("Delete", PopupIds.DELETE)
	else:
		add_item("Paste", PopupIds.PASTE, (KEY_MASK_CMD_OR_CTRL | KEY_V))

	set_item_disabled(get_item_index(PopupIds.PASTE), !_is_paste)


func _on_elements_menu_poped(
	element: Element,
	viewport_size: Vector2,
	is_group: bool = false,
	is_paste: bool = true
) -> void:

	_element = element
	_is_group = is_group
	_is_paste = is_paste

	clear()

	size.x = _defaul_width
	size.y = min_size.y
	popup(Rect2(0, 0, size.x, size.y))
	position = get_mouse_position()
	# add offset if out of the screen
	if (position.x + size.x) > viewport_size.x:
		position.x =  position.x - size.x
	if (position.y + size.y) > viewport_size.y:
		position.y =  position.y - size.y

	_reset()
