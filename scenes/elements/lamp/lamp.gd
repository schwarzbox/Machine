extends Element

const _on: Texture2D = preload("res://scenes/elements/lamp/lamp_on.png")
const _off: Texture2D = preload("res://scenes/elements/lamp/lamp_off.png")

func _ready() -> void:
	type = Globals.Elements.LAMP

	super()

func _has_energy() -> bool:
	for child in connectors_children:
		if child.type == Globals.Connectors.IN:
			if child.connected_has_energy():
				return true
	return false
