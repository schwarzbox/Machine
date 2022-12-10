extends Node

# shift straight lines

# less weird signals

# need to move wires together
# ?sorted wires?
# move if only wire?

# git merge collisions

# hertz forever ossci when start

# new A O !A !O# new battery

# show minimap?

# add text notes?

# highlight correct connector

# increase areas (how to highlight them)?

# add pixelate shader or texture for wire

# remove redudant methods?
# __ two underscores for my private
# add _private vars # element_draging $Connectors.get_children
# len or size?

# notification about and save + save before exit

# 1 byte memmory

# animate elements create, scale or particles sounds

# InputEventScreenTouch or InputEventMouseButton # input map
# check class and Packed Scene? names Camel

# graph nodes?
# read about resourses

# menu styles use dialogs popups with names for level menus
# style timer and anim for labels / remove labels

# refactoring
# use link instead connect
# info about element
# wire show symbol in wire create when can not be created
# hided menu hotkeys

# Check Project Settings Debug/Settings/ForceFPS and Display/Window/VSYNC
# Engine.set_target_fps(value)

# self.get_viewport().warp_mouse(instance.position)
# conver to CanvasLayer position
#self.get_global_transform_with_canvas().get_origin()

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
