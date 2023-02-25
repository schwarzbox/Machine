class_name Level

extends Node

export (Globals.Levels) var type

signal back_pressed

func _ready() -> void:
	$CanvasLayer/LevelMenu/Label.text = name

func _on_Back_pressed() -> void:
	emit_signal("back_pressed", self)
