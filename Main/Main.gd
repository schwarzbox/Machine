extends Node
# add bottom area-polygon colliders show areas where object could created


# not reconect when already connected wire when drag?
# check unlink error?

# move if only wire?

# remove redudant methods?
# __ two underscores for my private
# add _private vars # element_draging $Connectors.get_children

# add pixelate shader or texture for wire
# notification about and save + save before exit

# 1 byte memmory

# avoid elements (optimal path) 2D Pathfinding in under 6 minutes! Godot 3.5 Tutorial

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
	preload("res://Levels/Campaign/Campaign.tscn"),
	preload("res://Levels/Sandbox/Sandbox.tscn"),
	preload("res://Levels/Settings/Settings.tscn"),
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
	$Transition.fade(makeref, level)

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
