extends View

func _ready() -> void:
	prints(name, "ready")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed:
			if event.keycode == KEY_ESCAPE:
				emit_signal("view_exited", self)
			if event.keycode == KEY_R:
				emit_signal("view_restarted", self)
			if event.keycode == KEY_P:
				get_tree().paused = not get_tree().paused

func _on_back_pressed() -> void:
	emit_signal("view_exited", self)
