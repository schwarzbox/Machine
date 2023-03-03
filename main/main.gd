extends Node
# git
# add label settings for main menu
# refactor wire

# move to WFG scheme

# hertz scheme
# hertz elem

# notes tool (pop-up menu, main menu)
# highlight correct connector (if new art without color)

# new elements MV (rozetta?) ex_or ex_and
# new art A O !A !O battery

# 1 byte memmory

# IDEAS
# show minimap?

# clone outside safe?
# shift straight lines
# increase areas (how to highlight them)?
# add pixelate shader or texture for wire

# animate elements create, scale or particles sounds

# graph nodes?
# read about resourses

# anim for labels / remove labels
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

var _level_scenes := [
	preload("res://levels/campaign/campaign.tscn"),
	preload("res://levels/sandbox/sandbox.tscn"),
	preload("res://levels/settings/settings.tscn"),
]
var _levels: Array = []

func _ready() -> void:
	prints(name, "ready")

	# warning-ignore:return_value_discarded
	connect("tree_exiting",Callable(self,"_on_main_exited"))
	# warning-ignore:return_value_discarded
	$GUI.connect("button1_pressed",Callable(self,"_on_button1_pressed"))
	# warning-ignore:return_value_discarded
	$GUI.connect("button2_pressed",Callable(self,"_on_button2_pressed"))
	# warning-ignore:return_value_discarded
	$GUI.connect("button3_pressed",Callable(self,"_on_button3_pressed"))
	# warning-ignore:return_value_discarded
	$GUI.connect("button4_pressed",Callable(self,"_on_button4_pressed"))

	set_game()

func set_game() -> void:
	_levels.clear()

	for ls in _level_scenes:
		var node: Node = ls.instantiate()
		# warning-ignore:return_value_discarded
		node.connect("back_pressed",Callable(self,"_on_back_pressed"))
		_levels.append(node)

	$GUI.visible = true

func start(level) -> void:
	$World.add_child(level)

	if $World.get_child_count() > 0:
		$GUI.visible = false

func _set_transition(method: Callable, level: Node = null) -> void:
	Transition.fade(method, level)

func _on_button1_pressed() -> void:
	_set_transition(start, _levels[0])

func _on_button2_pressed() -> void:
	_set_transition(start, _levels[1])

func _on_button3_pressed() -> void:
	_set_transition(start, _levels[2])

func _on_button4_pressed() -> void:
	get_tree().quit()

func _on_back_pressed(level: Node) -> void:
	# restart levels
	level.queue_free()

	_set_transition(set_game)

func _on_main_exited() -> void:
	prints(name, "exited")
