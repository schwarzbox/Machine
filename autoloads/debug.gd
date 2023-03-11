extends Node

static func set_window_extended_info(node: Node) -> void:
	var title: String = ProjectSettings.get_setting("application/config/name")

	node.get_viewport().set_title(
		"Project: {title} | Node: {name} | Count: {count} | FPS: {fps}".format(
			{
				"title": title,
				"name": node.get_name(),
				"count": node.get_child_count(),
				"fps": str(Engine.get_frames_per_second())
			}
		)
	)
