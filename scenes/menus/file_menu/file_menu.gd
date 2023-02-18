extends HBoxContainer

var file_util: FileUtil = preload("res://utils/file_util.gd").new()

var _default_file_name: String = "untitled"
var _file_path: String = ""
var _after_save: FuncRef = null

signal menu_hided
signal file_name_changed
signal file_loaded
signal element_added
signal elements_deleted
signal sprite_showed
signal sprite_hided

func _ready() -> void:
	$FileDialog.current_dir = Globals.GAME.SAVE_GAME_DIR
	self._load_last_file()

func _load_last_file() -> void:
	var file_path = file_util.read_file(
		Globals.GAME.SAVE_GAME_DIR + Globals.GAME.LAST_FILE
	)
	if file_path:
		self._set_file_path(file_path)
		self._load()
	else:
		self._set_file_path(
			self._get_untitled_path(self._default_file_name)
		)

func _save_last_file_path() -> void:
	self.file_util.write_file(
		Globals.GAME.SAVE_GAME_DIR + Globals.GAME.LAST_FILE,
		self._file_path
	)

func _new() -> void:
	self.emit_signal("elements_deleted")

	self._set_file_path(
		self._get_untitled_path(self._default_file_name)
	)
	self.emit_signal("menu_hided")

	self._save_last_file_path()

func _save() -> void:
	file_util.save_elements_to(
		self._file_path,
		self.get_tree().get_nodes_in_group("Elements")
	)

	self._save_last_file_path()

func _load() -> void:
	self.emit_signal("elements_deleted")

	for element in file_util.load_elements_from(
		self._file_path
	):
		self.emit_signal("element_added", element)
		if element.type == Globals.Elements.WIRE:
			element.switch_connections()
			element.call_deferred("show_sprites")

	self.emit_signal("file_loaded")
	self._save_last_file_path()

func _open_dialog() -> void:
	$FileDialog.popup()
	$FileDialog.mode = FileDialog.MODE_OPEN_FILE
	$FileDialog.current_file = ""

func _save_dialog() -> void:
	$FileDialog.popup()
	$FileDialog.mode = FileDialog.MODE_SAVE_FILE
	$FileDialog.current_file = self._file_path.split('//')[-1]

func _set_file_path(path: String) -> void:
	self._file_path = path
	self.emit_signal("file_name_changed", self._file_path.split('//')[-1])

func _list_dir(path) -> Array:
	var dir = Directory.new()
	var list = []
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			list.append(file_name)
			file_name = dir.get_next()

	return list

func _get_untitled_path(file_name: String) -> String:
	var list_dir = self._list_dir(Globals.GAME.SAVE_GAME_DIR)
	var count = 1
	var new_name = file_name
	while new_name in list_dir:
		new_name = "{file_name}-{count}".format(
			{file_name=file_name, count=count}
		)
		count+=1

	return Globals.GAME.SAVE_GAME_DIR + new_name

func _has_unsaved_changes() -> bool:
	var elements = self.get_tree().get_nodes_in_group("Elements")
	var saved_elements = file_util.load_elements_from(self._file_path)

	if elements.size() != saved_elements.size():
		return true

	for element in elements:
		for saved_element in saved_elements:
			if element.name == saved_element.name:
				if (
					element.position != saved_element.position
					or element.scale != saved_element.scale
				):
					return true

				if element.type == Globals.Elements.WIRE:
					var points = element.get_points()
					var saved_points = saved_element.get_points()

					if (
						points[0] != saved_points[0]
						or points[1] != saved_points[1]
					):
						return true
	return false

func _on_New_pressed() -> void:
	if self._has_unsaved_changes():
		self._save_dialog()
		self._after_save = funcref(self, "_new")
	else:
		self._new()

func _on_Open_pressed() -> void:
	if self._has_unsaved_changes():
		self._save_dialog()
		self._after_save = funcref(self, "_open_dialog")
	else:
		self._open_dialog()

func _on_Save_As_pressed() -> void:
	self._save_dialog()

func _on_Save_pressed() -> void:
	self._save()
	self.emit_signal("menu_hided")

func _on_Load_pressed() -> void:
	self._load()
	self.emit_signal("menu_hided")

func _on_FileDialog_file_selected(path: String) -> void:
	if $FileDialog.mode == FileDialog.MODE_OPEN_FILE:
		self._set_file_path(path)
		self._load()
	elif $FileDialog.mode == FileDialog.MODE_SAVE_FILE:
		self._set_file_path(path)
		self._save()

func _on_FileDialog_popup_hide() -> void:
	if self._after_save:
		self._after_save.call_func()
		self._after_save = null
	else:
		self.emit_signal("menu_hided")

	self.emit_signal("sprite_showed")

func _on_FileDialog_mouse_entered() -> void:
	self.emit_signal("sprite_hided")

