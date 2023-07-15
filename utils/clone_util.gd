class_name CloneUtil

extends RefCounted

var _last_saved_elements: Array = []: get = get_last_saved_elements, set = set_last_saved_elements

func get_last_saved_elements() -> Array:
	return _last_saved_elements

func set_last_saved_elements(elements: Array) -> void:
	_last_saved_elements.clear()
	for element in elements:
		_last_saved_elements.append(_serialize(element))

func get_delta(pos: Vector2) -> Vector2:
	var delta = Vector2()
	for element in _last_saved_elements:
		delta += (pos - element.position)
	return delta / len(_last_saved_elements)

func duplicate(main: Node2D, elements: Array, delta: Vector2) -> void:
	var clones = []
	for element in elements:
		var scene: PackedScene = (
			Globals.ELEMENT_SCENES[element.type_name][0]
		)
		var clone: Element = scene.instantiate()
		main.add_child_element(clone)
		# to protect from wrong placement
		clone.last_valid_position = clone.position

		main.add_selected_element(clone)

		clone.position = element.position + delta
		clone.rotation = element.rotation

		if clone.type == Globals.Elements.WIRE:
			clone.set_points(element.points.duplicate())
		clones.append(clone)

		clone.set_is_cloned(true)

	# in separate cycle to save order
	for clone in clones:
		if clone.type == Globals.Elements.WIRE:
			clone.sync_wire_nodes()
			clone.call_deferred("show_sprites")
			clone.call_deferred("enable_first_connectors")

func _serialize(element: Element) -> Dictionary:
	var data: Dictionary = {
		"type_name": element.type_name,
		"position": element.position,
		"rotation": element.rotation,
		"points": []
	}
	if element.type == Globals.Elements.WIRE:
		data["points"] = element.get_points()
	return data
