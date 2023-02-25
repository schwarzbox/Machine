class_name PopupTools

extends PopupMenu

signal flip_pressed
signal clone_pressed
signal unlink_pressed
signal delete_pressed

enum PopupIds {
	HEADER,
	SEPARATOR,
	FLIP,
	CLONE,
	UNLINK,
	DELETE
}

var _element: Element = null
var _is_group: bool = false

func _on_PopupTools_id_pressed(id: int) -> void:
	if !_element:
		return

	match id:
		PopupIds.FLIP:
			emit_signal("flip_pressed")
		PopupIds.CLONE:
			emit_signal("clone_pressed")
		PopupIds.UNLINK:
			emit_signal("unlink_pressed")
		PopupIds.DELETE:
			emit_signal("delete_pressed")

	_is_group = false
	_element = null

func _on_PopupTools_about_to_show() -> void:
	if _element:
		add_separator('', PopupIds.HEADER)
		add_separator('', PopupIds.SEPARATOR)

		if _is_group:
			set_item_text(PopupIds.HEADER, "Group")
			add_item('Flip', PopupIds.FLIP)
		else:
			set_item_text(PopupIds.HEADER, _element.type_name)

			if _element.type != Globals.Elements.WIRE:
				add_item('Flip', PopupIds.FLIP)

		add_item('Clone', PopupIds.CLONE)
		add_item('Unlink', PopupIds.UNLINK)
		add_item('Delete', PopupIds.DELETE)

func _on_Objects_menu_poped(element: Element, is_group: bool = false) -> void:
	_is_group = is_group
	_element = element
	if _element:
		clear()
		rect_size = rect_min_size
		var mouse_pos = get_global_mouse_position()
		popup(Rect2(mouse_pos.x, mouse_pos.y, rect_size.x, rect_size.y))
	else:
		_is_group = false
		_element = null
