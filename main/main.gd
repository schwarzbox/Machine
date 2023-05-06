extends View
# pr memmory

# R
# move _elements_scenes in globals
# sort for reprsentation really heavy
# check wire get set (add_points, has_points)
# remove .owner references for connectors

# Q
# rotate with arrows near element? remove key rotation?
# how to move groups unlinked or linked? (maybe only if with wire?)

# B
# previous freed when disconent?

# F
# show minimap?
# notes tool (pop-up menu, main menu)
# copy among files
# highlight correct connector


# QUESTIONS
# select wire first or select element first?

# TUTORIAL/CAMPAIGN
# learn how to construct main all elements
# ocsialtor
# light bulbs
# counter freq (Hrz) = 256 / 10

# IDEAS
# BG pattern color?
# style for first menu
# create first screen image in mother board style
# add texture for wire (add wire shader or texture)
# animate elements create, scale or particles + sounds
# animate relay with tween or animation node?
# animate magnet field
# info about element more (in pop-up or on demand)
# remove help_label?

# read about resourses
# graph nodes?

# ELEMENTS
# Trigger Front with Pre and Clr
# JK trigger
# T Trigger

# IMPOSSIBLE BACKLOG
# connect wires without jump
# hertz blink
# _on_file_dialog_window_input (reset)

# HACKS
# GIF https://www.veed.io
# check FPS
# application/run/max_fps
# physics/common/physics_ticks_per_second

# force move mouse
# self.get_viewport().warp_mouse(instance.position)
#var viewport = _machine.get_viewport()
#viewport.warp_mouse(
#	mouse_pos *  _machine.actual_zoom + viewport.canvas_transform.origin
#)

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
