extends Reference

class_name FileUtil

func _serialize(element: Element) -> Dictionary:
	var data: Dictionary = {
		"filename": element.get_filename(),
		"name": String(element.get_name()),
		"position": element.position,
		"scale": element.scale,
		"points": []
	}
	if element.type == Globals.Elements.WIRE:
		data["points"] = element.get_points()
	return data

func _deserialize(data: Dictionary) -> Element:
	var element = load(data["filename"]).instance()
	element.name = String(data["name"])
	element.position = data["position"]
	element.scale = data["scale"]

	if element.type == Globals.Elements.WIRE:
		element.set_points(data["points"])

	return element

func save_elements_to(path: String, elements: Array) -> void:
	var file = File.new()
	file.open(path, File.WRITE)

	# number of elements
	file.store_16(elements.size())
	for element in elements:
		file.store_var(self._serialize(element), false)
	file.close()

func load_elements_from(path: String) -> Array:
	var elements: Array = []
	var file = File.new()
	if file.file_exists(path):
		file.open(path, File.READ)

		var number_elements = file.get_16()
		for _i in range(number_elements):
			elements.append(self._deserialize(file.get_var(false)))

		file.close()
	return elements

func write_file(path: String, content: String) -> void:
	var file = File.new()
	file.open(path, File.WRITE)
	file.store_string(content)
	file.close()

func read_file(path: String) -> String:
	var file = File.new()
	var content = ""
	if file.file_exists(path):
		file.open(path, File.READ)
		content = file.get_as_text()
		file.close()

	return content
