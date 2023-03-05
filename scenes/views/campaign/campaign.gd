extends View

func _ready() -> void:
	type = Globals.Levels.CAMPAIGN

#	add campaign levels

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			emit_signal("view_exited", self)
