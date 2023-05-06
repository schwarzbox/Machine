extends Element

const _on: Texture2D = preload("res://scenes/elements/lamp/lamp_on.png")
const _off: Texture2D = preload("res://scenes/elements/lamp/lamp_off.png")

func _ready() -> void:
	type = Globals.Elements.LAMP
	super()

func _has_energy() -> bool:
	return $Connectors/In.connected_has_energy()

