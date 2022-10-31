extends CanvasLayer

var reference: Reference = null
var level: Node = null

func _ready() -> void:
	prints(self.name, "ready")

func fade(ref: Reference, lvl: Node =null) -> void:
	self.reference = ref
	self.level = lvl
	$AnimationPlayer.play("Fade")

func _exe() -> void:
	if self.reference:
		if self.level:
			self.reference.call_func(self.level)
		else:
			self.reference.call_func()
