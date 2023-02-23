extends Label

func _on_help_showed(txt: String, position: Vector2, height: float) -> void:
	text = txt
	rect_position.x = position.x - rect_size.x / 2
	rect_position.y = position.y + height
	show()

func _on_help_hided() -> void:
	hide()
