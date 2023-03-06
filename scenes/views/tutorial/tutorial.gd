extends View

var _views: Array = []
var _views_scenes: Dictionary = {
	" - 1 - ": preload("res://scenes/views/tutorial/lessons/lesson1/lesson1.tscn")
}

func _ready() -> void:
	prints(name, "ready")
	type = Globals.Levels.TUTORIAL

	for node in [
		$CanvasLayer/Menu/VBoxContainer/Back
	]:
		node.add_theme_font_size_override(
			"font_size", Globals.FONTS.DEFAULT_FONT_SIZE
		)

	var keys = _views_scenes.keys()
	for i in range(keys.size()):
		var button: Button = Button.new()
		button.text = keys[i]
		button.connect("pressed", Callable(self, "_on_view_started").bind(i))
		button.add_theme_font_size_override(
			"font_size", Globals.FONTS.DEFAULT_FONT_SIZE
		)
		$CanvasLayer/Menu/VBoxContainer/GridContainer.add_child(button)

	_setup()

func _setup() -> void:
	_views.clear()

	for view_scene in _views_scenes.values():
		var node: Node = view_scene.instantiate()
		node.connect("view_restarted", self._on_view_restarted)
		node.connect("view_changed", self._on_view_changed)
		node.connect("view_exited", self._on_view_exited)
		_views.append(node)

	$CanvasLayer/Menu.show()

func _start(view: Node) -> void:
	add_world_child(view)

	if is_world_has_children():
		$CanvasLayer/Menu.hide()

func _change(view: Node) -> void:
	# save view state
	remove_world_child(view)

	var index: int = _views.find(view)
	if index < _views.size()-1:
		call_deferred("_start", _views[index+1])
	else:
		view.queue_free()
		call_deferred("_setup")

func _on_view_started(index: int) -> void:
	call_deferred("_start", _views[index])

func _on_view_restarted(view: Node) -> void:
	view.queue_free()
	var index: int = _views.find(view)
	_setup()
	call_deferred("_start", _views[index])

func _on_view_changed(view: Node) -> void:
	_set_transition(_change, view)

func _on_view_exited(view: Node) -> void:
	view.queue_free()
	_set_transition(_setup)

func _on_back_pressed() -> void:
	emit_signal("view_exited", self)
