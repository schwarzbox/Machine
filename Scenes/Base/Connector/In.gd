extends Connector

func _ready() -> void:
	self.set_collision_layer_bit(1, true)
	self.set_collision_mask_bit(2, true)

	self.type = Globals.Connectors.IN
