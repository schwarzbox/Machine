extends Connector

func _ready() -> void:
	set_collision_layer_bit(2, true)
	set_collision_mask_bit(1, true)

	type = Globals.Connectors.OUT
