extends View

func _ready() -> void:
	prints(name, "ready")
	type = Globals.Levels.SETTINGS

	for node in [
		$CanvasLayer/Menu/VBoxContainer/Back
	]:
		node.add_theme_font_size_override(
			"font_size", Globals.FONTS.DEFAULT_FONT_SIZE
		)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			emit_signal("view_exited", self)

func _on_back_pressed() -> void:
	emit_signal("view_exited", self)
