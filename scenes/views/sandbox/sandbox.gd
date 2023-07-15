extends View

signal about_to_save

func _ready() -> void:
	prints(name, "ready")
	type = Globals.Levels.SANDBOX

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed:
			if event.keycode == KEY_P:
				get_tree().paused = not get_tree().paused

func _process_unsaved_changes() -> void:
	if $CanvasLayer/LevelMenu/Info/FileMenu.has_unsaved_changes():
		emit_signal("about_to_save")
		await $CanvasLayer/LevelMenu/Info/FileMenu.file_saved

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		get_tree().set_auto_accept_quit(false)
		await _process_unsaved_changes()
		get_tree().quit()

func _on_back_pressed() -> void:
	await _process_unsaved_changes()
	emit_signal("view_exited", self)



