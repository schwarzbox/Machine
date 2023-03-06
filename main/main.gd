extends View
# merge
# try top-down elem

# clone outside safe area?
# shift straight lines

# new elements MV (rozetta?) ex_or ex_and
# new art A O !A !O battery
# hertz elem

# notes tool (pop-up menu, main menu)
# highlight correct connector (if new art without color)

# 1 byte memmory

# IDEAS
# show minimap?

# increase areas (how to highlight them)?
# add pixelate shader or texture for wire
# remove .owner references for connectors
# remove help_label

# animate elements create, scale or particles + sounds

# graph nodes?
# read about resourses

# info about element more (in pop-up or on demand)

# IMPOSSIBLE BACKLOG
# hertz blink
# add wire shader or texture
# _on_file_dialog_window_input (reset)

# HACKS
# check FPS
# debug/settings/fps/force_fps
# application/run/max_fps
# physics/common/physics_ticks_per_second
# physics/common/physics_ticks_per_second

# force move mouse
# self.get_viewport().warp_mouse(instance.position)

# convert to CanvasLayer position
# self.get_global_transform_with_canvas().get_origin()

var _views: Array = []
var _views_scenes = [
	preload("res://scenes/views/tutorial/tutorial.tscn"),
	preload("res://scenes/views/campaign/campaign.tscn"),
	preload("res://scenes/views/sandbox/sandbox.tscn"),
	preload("res://scenes/views/settings/settings.tscn")
]

func _ready() -> void:
	prints(name, "ready")

	randomize()

	for button in [
		$CanvasLayer/Menu/VBoxContainer/Tutorial,
		$CanvasLayer/Menu/VBoxContainer/Campaign,
		$CanvasLayer/Menu/VBoxContainer/Sandbox,
		$CanvasLayer/Menu/VBoxContainer/Settings,
		$CanvasLayer/Menu/VBoxContainer/Exit
	]:
		button.add_theme_font_size_override(
			"font_size", Globals.FONTS.DEFAULT_FONT_SIZE
		)

	# warning-ignore:return_value_discarded
	connect("tree_exiting", self._on_main_exited)

	_setup()

func _setup() -> void:
	_views.clear()

	for view in _views_scenes:
		var node: Node = view.instantiate()
		# warning-ignore:return_value_discarded
		node.connect("view_exited", self._on_view_exited)
		_views.append(node)

	$CanvasLayer/Menu.show()

func _start(view: Node) -> void:
	add_world_child(view)

	if is_world_has_children():
		$CanvasLayer/Menu.hide()

func _on_tutorial_pressed() -> void:
	_set_transition(_start, _views[0])

func _on_campaign_pressed() -> void:
	_set_transition(_start, _views[1])

func _on_sandbox_pressed() -> void:
	_set_transition(_start, _views[2])

func _on_settings_pressed() -> void:
	_set_transition(_start, _views[3])

func _on_view_exited(view: Node) -> void:
	view.queue_free()
	_set_transition(_setup)

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_main_exited() -> void:
	prints(name, "exited")
