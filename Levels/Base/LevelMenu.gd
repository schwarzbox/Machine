extends VBoxContainer

signal sprite_showed
signal sprite_hided

func _ready() -> void:
	self.hide_menu()
	self._update_rect_size()

func _update_rect_size():
	self.rect_size = self.rect_min_size
	self.margin_left = 0
	self.margin_right = 0

func _unhandled_input(event) -> void:
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ESCAPE:
			if $Info.visible:
				self.hide_menu()
			else:
				self.show_menu()

func show_menu():
	$Info.show()

func hide_menu():
	$Info.hide()

func _on_LevelMenu_mouse_entered() -> void:
	self.emit_signal("sprite_hided")

func _on_LevelMenu_mouse_exited() -> void:
	self.emit_signal("sprite_showed")

func _on_HideButton_pressed() -> void:
	if $Info.visible:
		self.hide_menu()
	else:
		self.show_menu()

	self._update_rect_size()

func _on_FileMenu_menu_hided() -> void:
	self.hide_menu()

func _on_FileMenu_file_name_changed(txt: String) -> void:
	$Info/Label.text = txt
