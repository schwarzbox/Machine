extends View
# finish pr

# 1 byte memmory
# clone wire group?
# select wire first or select element first
# drag shift

# unlink problem (error)
# previous freed when disconent?

# how to move groups unlink or link

# check wrap mouse


# check old saves
# move _elements_scenes in globals
# cursor outside screen hide element and show cursor
# rotate menu when in the bottom

# clone and not move stay in safe area

# rotate with arrows near element
# copy among files

# Share build (franca beta testers)

# highlight correct connector
# check wire get set (add_points, has_points)
# sort for reprsentation really heavy!

# create first screen image in mother board style
# style for first menu
# try theme miniamlist

# remove .owner references for connectors
# notes tool (pop-up menu, main menu)

# read about resourses

# TUTORIAL/CAMPAIGN
# construct main all elements
# ocsialtor
# light bulbs

# IDEAS
# add texture for wire (add wire shader or texture)
# animate elements create, scale or particles + sounds
# animate relay with tween or animation node?
# animate magnet field
# info about element more (in pop-up or on demand)
# remove help_label?
# show minimap?

# graph nodes?

# IMPOSSIBLE BACKLOG
# hertz blink
# _on_file_dialog_window_input (reset)

# HACKS
# GIF https://www.veed.io
# check FPS
# application/run/max_fps
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
