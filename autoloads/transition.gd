extends CanvasLayer

var _reference: Reference = null
var _level: Node = null

func _ready() -> void:
	prints(name, "ready")

func fade(reference: Reference, level: Node =null) -> void:
	_reference = reference
	_level = level
	$AnimationPlayer.play("Fade")

func _exe() -> void:
	if _reference:
		if _level:
			_reference.call_func(_level)
		else:
			_reference.call_func()
