class_name Cursor

extends Sprite2D

# maybe exists better solution
# to check when cursor in safe area
const type: int = Globals.GAME.CURSOR_TYPE

var _cursor_texture: Texture2D = null

func _show_sprite(tx: Texture2D = null) -> void:
	$Area2D.show()
	$Area2D/CollisionShape2D.disabled = false

	if tx:
		texture = tx
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	elif _cursor_texture:
		texture = _cursor_texture
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	else:
		_hide_sprite()

func _hide_sprite() -> void:
	$Area2D.hide()
	$Area2D/CollisionShape2D.disabled = true

	texture = null
	position = Vector2()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_file_menu_sprite_showed() -> void:
	_show_sprite()

func  _on_file_menu_sprite_hided() -> void:
	_hide_sprite()

func _on_element_menu_sprite_showed() -> void:
	_show_sprite()

func _on_element_menu_sprite_hided() -> void:
	_hide_sprite()

func _on_level_menu_sprite_showed() -> void:
	_show_sprite()

func _on_level_menu_sprite_hided() -> void:
	_hide_sprite()

func _on_elements_sprite_showed(tx: Texture2D = null) -> void:
	_show_sprite(tx)

func _on_elements_sprite_hided() -> void:
	_hide_sprite()

func _on_elements_sprite_texture_saved(
	tx: Texture2D, size: Vector2, is_element: bool
) -> void:
	$Area2D/CollisionShape2D.shape.size = size
	_cursor_texture = tx
	material.set_shader_parameter("is_element", is_element)

func _on_elements_sprite_texture_removed() -> void:
	_cursor_texture = null

func _on_elements_sprite_position_updated(pos: Vector2) -> void:
	position = pos

func _on_elements_cursor_shape_updated(shape: int) -> void:
	Input.set_default_cursor_shape(shape)

