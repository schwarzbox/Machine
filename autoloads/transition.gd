extends CanvasLayer

var _callable: Callable = Callable()
var _level: Node = null

func _ready() -> void:
	prints(name, "ready")

func fade(callable: Callable, level: Node = null) -> void:
	_callable = callable
	_level = level
	$AnimationPlayer.play("Fade")

func _exe() -> void:
	if _callable:
		if _level:
			_callable.call(_level)
		else:
			_callable.call()
