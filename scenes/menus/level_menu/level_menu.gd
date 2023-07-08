extends VBoxContainer

# Cursor
signal sprite_hided
signal sprite_showed

func _ready() -> void:
	_hide_menu()

	for node in [$Info/Back, $HideButton]:
		node.add_theme_font_size_override(
			"font_size", Globals.FONTS.DEFAULT_FONT_SIZE
		)

func _unhandled_input(event) -> void:
	if event is InputEventKey:
		if event.pressed && event.keycode == KEY_ESCAPE:
			if $Info.visible:
				_hide_menu()
			else:
				_show_menu()

func _show_menu():
	$Info.show()
	_update_rect_size()

func _hide_menu():
	$Info.hide()
	_update_rect_size()

func _update_rect_size():
	size = custom_minimum_size
	offset_left = 0
	offset_right = 0

func _on_mouse_entered() -> void:
	emit_signal("sprite_hided")

func _on_mouse_exited() -> void:
	emit_signal("sprite_showed")

func _on_hide_button_pressed() -> void:
	if $Info.visible:
		_hide_menu()
	else:
		_show_menu()

func _on_file_menu_menu_hided() -> void:
	_hide_menu()

func _on_file_menu_file_name_changed(txt: String) -> void:
	$Info/MenuLabel.text = txt

