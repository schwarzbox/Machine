extends Node

# add special cursor for select mode, drag mode
# hertz forever ossci when start


# __ two underscores for my private? refactor _actual_zoom and other private vars and func
# remove redudant methods/calls?
# check class and Packed Scene? names Camel

# notification about and save + save before exit

# wire sort
# read about graphics
# new art A O !A !O  battery
# 1 byte memmory
# new elemnts

# IDEAS
# show minimap?
# note-tags tool in menu
# highlight correct connector
# shift straight lines
# increase areas (how to highlight them)?
# add pixelate shader or texture for wire

# animate elements create, scale or particles sounds

# graph nodes?
# read about resourses

# menu styles use dialogs popups with names for level menus
# style timer and anim for labels / remove labels

# refactoring
# info about element
# hided menu hotkeys

# HACKS
# Check Project Settings Debug/Settings/ForceFPS and Display/Window/VSYNC
# Engine.set_target_fps(value)

# self.get_viewport().warp_mouse(instance.position)
# convert to CanvasLayer position
# self.get_global_transform_with_canvas().get_origin()

var level_scenes := [
	preload("res://levels/campaign/campaign.tscn"),
	preload("res://levels/sandbox/sandbox.tscn"),
	preload("res://levels/settings/settings.tscn"),
]
var levels: Array = []

func _ready() -> void:
	prints(self.name, "ready")

	print(self.connect("tree_exiting", self, "_on_Main_exited"))
	print($GUI.connect("button1_pressed", self, "_on_Button1_pressed"))
	print($GUI.connect("button2_pressed", self, "_on_Button2_pressed"))
	print($GUI.connect("button3_pressed", self, "_on_Button3_pressed"))
	print($GUI.connect("button4_pressed", self, "_on_Button4_pressed"))

	self.set_game()

func set_game() -> void:
	self.levels.clear()

	for ls in self.level_scenes:
		var node: Node = ls.instance()
		print(node.connect("back_pressed", self, "_on_Back_pressed"))
		self.levels.append(node)

	$GUI.visible = true

func start(level) -> void:
	$World.add_child(level)

	if $World.get_child_count() > 0:
		$GUI.visible = false

func _set_transition(call: String, level: Node = null) -> void:
	var makeref = funcref(self, call)
	Transition.fade(makeref, level)

func _on_Button1_pressed() -> void:
	self._set_transition("start", self.levels[0])

func _on_Button2_pressed() -> void:
	self._set_transition("start", self.levels[1])

func _on_Button3_pressed() -> void:
	self._set_transition("start", self.levels[2])

func _on_Button4_pressed() -> void:
	self.get_tree().quit()

func _on_Back_pressed(level: Node) -> void:
	# restart levels
	level.queue_free()

	self._set_transition("set_game")

func _on_Main_exited() -> void:
	prints(self.name, "exited")
