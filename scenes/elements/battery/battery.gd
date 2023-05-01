extends Element

const _off: Texture2D = preload("res://scenes/elements/battery/battery.png")
const _on: Texture2D = preload("res://scenes/elements/battery/battery.png")

func _ready() -> void:
	type = Globals.Elements.BATTERY
	add_to_group("Energy")
	super()

func _has_energy() -> bool:
	$Connectors/Out.set_energy(true)
	return true
