extends View

func _ready() -> void:
	type = Globals.Levels.SANDBOX

func _on_back_pressed() -> void:
	emit_signal("view_exited", self)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed:
			if event.keycode == KEY_P:
				get_tree().paused = not get_tree().paused
