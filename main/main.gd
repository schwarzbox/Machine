extends Node
# notification about and save + save before exit

# new elemnts MV (rozetta?)

# godot4 (read about graphics)

# tag tool in pop-up menu
# highlight correct connector

# hertz blink

# new art A O !A !O battery

# 1 byte memmory

# IDEAS
# show minimap?

# shift straight lines
# increase areas (how to highlight them)?
# add pixelate shader or texture for wire

# animate elements create, scale or particles sounds

# graph nodes?
# read about resourses

# menu styles
# use dialogs popups with names for level menus
# style timer and anim for labels / remove labels

# info about element
# hided menu hotkeys

# HACKS
# Check Project Settings Debug/Settings/ForceFPS and Display/Window/VSYNC
# Engine.set_target_fps(value)

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
	connect("tree_exiting", self, "_on_Main_exited")
	# warning-ignore:return_value_discarded
	$GUI.connect("button1_pressed", self, "_on_Button1_pressed")
	# warning-ignore:return_value_discarded
	$GUI.connect("button2_pressed", self, "_on_Button2_pressed")
	# warning-ignore:return_value_discarded
	$GUI.connect("button3_pressed", self, "_on_Button3_pressed")
	# warning-ignore:return_value_discarded
	$GUI.connect("button4_pressed", self, "_on_Button4_pressed")

	set_game()

func set_game() -> void:
	_levels.clear()

	for ls in _level_scenes:
		var node: Node = ls.instance()
		# warning-ignore:return_value_discarded
		node.connect("back_pressed", self, "_on_Back_pressed")
		_levels.append(node)

	$GUI.visible = true

func start(level) -> void:
	$World.add_child(level)

	if $World.get_child_count() > 0:
		$GUI.visible = false

func _set_transition(call: String, level: Node = null) -> void:
	var makeref = funcref(self, call)
	Transition.fade(makeref, level)

func _on_Button1_pressed() -> void:
	_set_transition("start", _levels[0])

func _on_Button2_pressed() -> void:
	_set_transition("start", _levels[1])

func _on_Button3_pressed() -> void:
	_set_transition("start", _levels[2])

func _on_Button4_pressed() -> void:
	get_tree().quit()

func _on_Back_pressed(level: Node) -> void:
	# restart levels
	level.queue_free()

	_set_transition("set_game")

func _on_Main_exited() -> void:
	prints(name, "exited")
