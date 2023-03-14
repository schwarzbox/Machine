class_name ColorLabel

extends Label

func _on_help_showed(txt: String, position: Vector2, height: float) -> void:
	text = txt
	position.x = position.x - size.x / 2
	position.y = position.y + height
	show()

func _on_help_hided() -> void:
	hide()
