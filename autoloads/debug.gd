extends Node

func set_window_extended_info(node: Node) -> void:
	var title: String = ProjectSettings.get_setting("application/config/name")
	var elements = node.get_node_or_null("World/Elements")
	node.get_viewport().set_title(
		"Project: {title} | Node: {name} | Count: {count} | Elements: {elem} | FPS: {fps}".format(
			{
				"title": title,
				"name": node.get_name(),
				"count": node.get_child_count(),
				"elem": elements.get_child_count() if elements else 0,
				"fps": str(Engine.get_frames_per_second())
			}
		)
	)
