extends PopupMenu

class_name PopupTools

var _element: Element = null
var _is_group: bool = false

enum PopupIds {
	HEADER,
	SEPARATOR,
	FLIP,
	CLONE,
	UNLINK,
	DELETE
}

signal flip_pressed
signal clone_pressed
signal unlink_pressed
signal delete_pressed

func _on_PopupTools_id_pressed(id: int) -> void:
	if not self._element:
		return

	match id:
		PopupIds.FLIP:
			self.emit_signal("flip_pressed")
		PopupIds.CLONE:
			self.emit_signal("clone_pressed")
		PopupIds.UNLINK:
			self.emit_signal("unlink_pressed")
		PopupIds.DELETE:
			self.emit_signal("delete_pressed")

	self._is_group = false
	self._element = null

func _on_PopupTools_about_to_show() -> void:
	if self._element:
		self.add_separator('', PopupIds.HEADER)
		self.add_separator('', PopupIds.SEPARATOR)

		if self._is_group:
			self.set_item_text(PopupIds.HEADER, "Group")
			self.add_item('Flip', PopupIds.FLIP)
		else:
			self.set_item_text(PopupIds.HEADER, self._element.get_type_name())

			if self._element.type != Globals.Elements.WIRE:
				self.add_item('Flip', PopupIds.FLIP)

		self.add_item('Clone', PopupIds.CLONE)
		self.add_item('Unlink', PopupIds.UNLINK)
		self.add_item('Delete', PopupIds.DELETE)

func _on_Objects_menu_poped(element: Element, is_group: bool = false) -> void:
	self._is_group = is_group
	self._element = element
	if self._element:
		self.clear()

		self.rect_size = self.rect_min_size
		var mouse_pos = self.get_global_mouse_position()
		self.popup(
			Rect2(
				mouse_pos.x, mouse_pos.y,
				self.rect_size.x, self.rect_size.y
			)
		)
	else:
		self._is_group = false
		self._element = null
