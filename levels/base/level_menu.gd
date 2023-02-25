extends VBoxContainer

signal sprite_showed
signal sprite_hided

func _ready() -> void:
	hide_menu()
	_update_rect_size()

func _unhandled_input(event) -> void:
	if event is InputEventKey:
		if event.pressed && event.scancode == KEY_ESCAPE:
			if $Info.visible:
				hide_menu()
			else:
				show_menu()

func show_menu():
	$Info.show()

func hide_menu():
	$Info.hide()

func _update_rect_size():
	rect_size = rect_min_size
	margin_left = 0
	margin_right = 0

func _on_LevelMenu_mouse_entered() -> void:
	emit_signal("sprite_hided")

func _on_LevelMenu_mouse_exited() -> void:
	emit_signal("sprite_showed")

func _on_HideButton_pressed() -> void:
	if $Info.visible:
		hide_menu()
	else:
		show_menu()
	_update_rect_size()

func _on_FileMenu_menu_hided() -> void:
	hide_menu()

func _on_FileMenu_file_name_changed(txt: String) -> void:
	$Info/Label.text = txt
