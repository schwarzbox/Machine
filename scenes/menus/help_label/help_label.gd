extends Label

func _on_help_showed(txt: String, position: Vector2, height: float) -> void:
	self.text = txt
	self.rect_position.x = position.x - self.rect_size.x / 2
	self.rect_position.y = position.y + height
	self.show()

func _on_help_hided() -> void:
	self.hide()
