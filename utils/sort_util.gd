class_name SortUtil

extends Resource

static func _sort_by_position(a: Element, b: Element):
	if a.position > b.position:
		return true
	return false

static func _sort_by_rect_bottom_side(a: Element, b: Element):
	var a_sorting_position = Vector2()
	var b_sorting_position = Vector2()
	var a_size = a.sprite_size / 2
	var b_size = b.sprite_size / 2
	a_sorting_position.y = a.position.y + a_size.y
	b_sorting_position.y = b.position.y + b_size.y

	if a_sorting_position.y < b_sorting_position.y:
		return true
	return false
