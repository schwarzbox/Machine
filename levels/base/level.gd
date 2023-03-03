class_name Level

extends Node

@export var type: Globals.Levels

signal back_pressed

func _ready() -> void:
	$CanvasLayer/LevelMenu/Label.text = name

func _on_back_pressed() -> void:
	emit_signal("back_pressed", self)

