extends VBoxContainer

func _ready() -> void:
	_hide_menu()

	for node in [$HideButton]:
		node.add_theme_font_size_override(
			"font_size", Globals.FONTS.DEFAULT_FONT_SIZE
		)


func _show_menu():
	$SubViewportContainer.show()
	_update_rect_size()
	$SubViewportContainer/Minimap.gui_disable_input = false

func _hide_menu():
	$SubViewportContainer.hide()
	_update_rect_size()
	$SubViewportContainer/Minimap.gui_disable_input = true

func _update_rect_size():
	size = custom_minimum_size
	offset_left = 0
	offset_right = 0
	offset_top = 0
	offset_bottom = 0

func _on_hide_button_pressed() -> void:
	if $SubViewportContainer.visible:
		_hide_menu()
	else:
		_show_menu()
