extends Connector

func _ready() -> void:
	set_collision_layer_value(1, true)
	set_collision_mask_value(2, true)

	type = Globals.Connectors.IN
