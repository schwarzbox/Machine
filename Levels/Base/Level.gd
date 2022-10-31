extends Node

class_name Level

export (Globals.LEVELS) var type

signal back_pressed

func _ready() -> void:
	$CanvasLayer/LevelMenu/Label.text = self.name

func _on_Back_pressed() -> void:
	self.emit_signal("back_pressed", self)
