extends View
# move groups linked
# update readme and image
# v0.15

# Add pause mode in wfg (stack machine)

# add calculator example
# scheme display numbers (how to construct pixel monitor)?

# add dynamic/bipper

# optimize drag after 1000 elements


# allow to connect to connected wire
# check how wire created automatically
# add wire after drop (connect wires without jump)?

# F
# cmd z cmd shift z undo? save diff state?
# notes tool (pop-up menu, main menu)

# E
# trigger preset
# decoder 2 - 4?

# R
# check all get set (# check wire get set (add_points, has_points))
# move mouse cursors managment in sep method (and check events)
# remove .owner references for connectors
# remove help_label?
# remove adder 8 bit

# Q
# how to save programms?

# B
# bug with stop calculation?
# previous freed when disconent?

# TUTORIAL/CAMPAIGN
# learn how to construct all elements
# ocsialtor
# light up bulbs
# counter freq (Hrz) = 256 / 10
# blink lamps
# blink lamps diff modes
# calculator
# show numbers with displays

# IDEAS
# icons to save load new messages
# reset_scale to animate creation
# wire in the minimap
# BG pattern color?
# style for first menu
# create first screen image in mother board style
# add texture for wire (add wire shader or texture)
# animate elements create, scale or particles + sounds
# animate relay with tween or animation node?
# animate magnet field
# info about element more (in pop-up or on demand)

# read about resourses
# graph nodes?


# IMPOSSIBLE BACKLOG
# ram blink energy elements 000
# hertz blink
# _on_file_dialog_window_input (reset)

# HACKS
# check FPS
# application/run/max_fps
# physics/common/physics_ticks_per_second

# static
# force move mouse
# self.get_viewport().warp_mouse(instance.position)
#var viewport = _main.get_viewport()
#viewport.warp_mouse(
#	mouse_pos *  _main.actual_zoom + viewport.canvas_transform.origin
#)

# Button is being triggered by spacebar after clicked once.
#Project Settings -> Input Map and remove the space bar from ui_accept.

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
