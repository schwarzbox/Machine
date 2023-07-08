extends HBoxContainer

# Elements
signal element_added
signal elements_deleted
# Camera2D
signal file_loaded
# LevelMenu
signal file_name_changed
# LevelMenu
signal menu_hided
# Cursor
signal sprite_hided
signal sprite_showed

const _default_file_name: String = Globals.GAME.DEFAULT_FILE_NAME

var _file_util: FileUtil = preload("res://utils/file_util.gd").new()
var _file_path: String = ""
var _after_save: Callable = Callable()

func _ready() -> void:
	for node in [$New, $Open, $"Save As", $Save, $Load]:
		node.add_theme_font_size_override(
			"font_size", Globals.FONTS.DEFAULT_FONT_SIZE
		)
	# set ext filter
	$FileDialog.add_filter("*.{ext}".format({ext=Globals.GAME.FILE_EXTENSION}))

	_load_last_file()

	$FileDialog.current_dir = _file_path.get_base_dir()

	$SaveDialog.dialog_text = "Do you want to save changes?"
	$SaveDialog.reset_size()

	$NotificationTimer.wait_time = Globals.GAME.NOTIFICATION_DELAY

func _get_untitled_path(file_name: String) -> String:
	var list_dir = _get_list_dir($FileDialog.current_dir)

	var count = 1
	var new_name = "{base_name}.{ext}".format(
		{base_name=file_name, ext=Globals.GAME.FILE_EXTENSION}
	)
	while new_name in list_dir:
		var base_name = file_name.get_basename()
		new_name = "{base_name}-{count}.{ext}".format(
			{base_name=file_name, count=count, ext=Globals.GAME.FILE_EXTENSION}
		)
		count += 1

	return $FileDialog.current_dir.path_join(new_name)

func _load_last_file() -> void:
	var file_path = _file_util.read_file(
		Globals.GAME.SAVE_GAME_DIR.path_join(Globals.GAME.LAST_FILE)
	)

	if file_path:
		_set_file_path(file_path)
		_load()
	else:
		_set_file_path(_get_untitled_path(_default_file_name))

func _save_last_file_path() -> void:
	self._file_util.write_file(
		Globals.GAME.SAVE_GAME_DIR.path_join(Globals.GAME.LAST_FILE),
		_file_path
	)

func _notify(txt: String) -> void:
	$Notification/MenuLabel.text = " {txt}: {file_name} ".format(
		{txt=txt, file_name=_file_path.get_file()}
	)
	$Notification.reset_size()
	$Notification.popup()

	$NotificationTimer.start()
	await $NotificationTimer.timeout
	$Notification.hide()

func _new() -> void:
	emit_signal("elements_deleted")

	_set_file_path(_get_untitled_path(_default_file_name))
	emit_signal("menu_hided")

	_notify("Created")
	_save_last_file_path()

func _save() -> void:
	_file_util.save_elements_to(
		_file_path,
		get_tree().get_nodes_in_group("Elements")
	)
	_notify("Saved")
	_save_last_file_path()

func _load() -> void:
	emit_signal("elements_deleted")

	for element in _file_util.load_elements_from(_file_path):
		emit_signal("element_added", element)

		if element.type == Globals.Elements.WIRE:
			element.sync_wire_nodes()
			element.call_deferred("show_sprites")
			# to correctly connect wire when draw
			element.call_deferred("enable_first_connectors")

	emit_signal("file_loaded")

	_notify("Loaded")
	_save_last_file_path()

func _open_dialog() -> void:
	$FileDialog.popup()
	$FileDialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	$FileDialog.current_file = ""
	$FileDialog.deselect_all()

func _save_dialog() -> void:
	$FileDialog.popup()
	$FileDialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	$FileDialog.current_file = _file_path.get_slice('//', 1)

func _set_file_path(path: String) -> void:
	_file_path = "{base_name}.{ext}".format(
		{base_name=path.get_basename(), ext=Globals.GAME.FILE_EXTENSION}
	)
	emit_signal("file_name_changed", _file_path.get_file())

func _get_list_dir(path) -> Array:
	var dir = DirAccess.open(path)
	var list = []
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			list.append(file_name)
			file_name = dir.get_next()
	return list

func _has_unsaved_changes() -> bool:
	var elements = get_tree().get_nodes_in_group("Elements")
	var saved_elements = _file_util.load_elements_from(_file_path)

	if elements.size() != saved_elements.size():
		return true

	for element in elements:
		for saved_element in saved_elements:
			if element.name == saved_element.name:
				if (
					element.position != saved_element.position
					|| element.rotation != saved_element.rotation
				):
					return true

				if element.type == Globals.Elements.WIRE:
					var points = element.get_points()
					var saved_points = saved_element.get_points()

					if (
						points[0] != saved_points[0]
						|| points[1] != saved_points[1]
					):
						return true
	return false

func _on_new_pressed() -> void:
	if _has_unsaved_changes():
		# show pop-up
		$SaveDialog.popup()
		_after_save = _new
	else:
		_new()

func _on_open_pressed() -> void:
	if _has_unsaved_changes():
		$SaveDialog.popup()
		_after_save = _open_dialog
	else:
		_open_dialog()

func _on_save_as_pressed() -> void:
	_save_dialog()

func _on_save_pressed() -> void:
	_save()
	emit_signal("menu_hided")

func _on_load_pressed() -> void:
	_load()
	emit_signal("menu_hided")

func _dialog_closed() -> void:
	if _after_save:
		_after_save.call_deferred()
		_after_save = Callable()
	else:
		emit_signal("menu_hided")

	emit_signal("sprite_showed")

func _on_file_dialog_about_to_popup() -> void:
	var pos = (get_viewport().size / 2) - $FileDialog.size / 2
	$FileDialog.position = Vector2(pos.x, 0)
#
func _on_file_dialog_file_selected(path: String) -> void:
	if $FileDialog.file_mode == FileDialog.FILE_MODE_OPEN_FILE:
		_set_file_path(path)
		_load()
	elif $FileDialog.file_mode == FileDialog.FILE_MODE_SAVE_FILE:
		_set_file_path(path)
		_save()

	_dialog_closed()

func _on_file_dialog_canceled() -> void:
	_dialog_closed()

func _on_file_dialog_mouse_entered() -> void:
	emit_signal("sprite_hided")

func _on_file_dialog_window_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode in [
			KEY_META,
			KEY_CTRL,
			KEY_DELETE,
			KEY_BACKSPACE,
			KEY_LEFT,
			KEY_RIGHT
		]:
			pass
		else:
			var list_dir = _get_list_dir($FileDialog.current_dir)
			if $FileDialog.current_file in list_dir:
				$FileDialog.call_deferred('invalidate')

func _on_save_dialog_about_to_popup() -> void:
	var pos = (get_viewport().size / 2) - $SaveDialog.size / 2
	$SaveDialog.position = Vector2(pos.x, 0)

func _on_save_dialog_confirmed() -> void:
	_save_dialog()

func _on_save_dialog_canceled() -> void:
	_dialog_closed()

func _on_mouse_entered() -> void:
	emit_signal("sprite_hided")

func _on_mouse_exited() -> void:
	emit_signal("sprite_showed")

func _on_notification_about_to_popup() -> void:
	var pos = (get_viewport().size / 2) - 	$Notification.size / 2
	$Notification.position = Vector2(pos.x, 0)

func _on_notification_close_requested() -> void:
	$NotificationTimer.stop()
