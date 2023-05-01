class_name FileUtil

extends RefCounted

func save_elements_to(path: String, elements: Array) -> void:
	var file = FileAccess.open(path, FileAccess.WRITE)

	# number of elements
	file.store_16(elements.size())
	for element in elements:
		file.store_var(_serialize(element), false)
	file.close()

func load_elements_from(path: String) -> Array:
	var elements: Array = []
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var number_elements = file.get_16()
		for _i in range(number_elements):
			elements.append(_deserialize(file.get_var(false)))

		file.close()
	return elements

func write_file(path: String, content: String) -> void:
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(content)
	file.close()

func read_file(path: String) -> String:
	var file = FileAccess.open(path, FileAccess.READ)
	var content = ""
	if file:
		content = file.get_as_text()
		file.close()

	return content

func _serialize(element: Element) -> Dictionary:
	var data: Dictionary = {
		"filename": element.get_scene_file_path(),
		"name": String(element.get_name()),
		"position": element.position,
		"rotation": element.rotation,
		"points": []
	}
	if element.type == Globals.Elements.WIRE:
		data["points"] = element.get_points()
	return data

func _deserialize(data):
	var element = load(data["filename"]).instantiate()
	element.name = String(data["name"])
	element.position = data["position"]
	element.rotation = data["rotation"]

	if element.type == Globals.Elements.WIRE:
		element.set_points(data["points"])

	return element
