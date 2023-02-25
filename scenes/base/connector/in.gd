extends Connector

func _ready() -> void:
	set_collision_layer_bit(1, true)
	set_collision_mask_bit(2, true)

	type = Globals.Connectors.IN
