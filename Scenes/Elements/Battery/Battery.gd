extends Element

const _on: Texture = preload("res://scenes/elements/battery/battery.png")
const _off: Texture = preload("res://scenes/elements/battery/battery.png")

func _ready() -> void:
	self.type = Globals.Elements.BATTERY

	self.add_to_group("Energy")

func __has_energy() -> bool:
	$Connectors/Out.set_energy(true)
	$Connectors/Out2.set_energy(true)
	return true
