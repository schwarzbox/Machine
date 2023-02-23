class_name Cursor

extends Sprite

# maybe exists better solution
# to check when cursor in safe area
const type: int = -1

var _cursor_texture: Texture = null

func _set_position(pos: Vector2 = Vector2()) -> void:
	position = pos

func _show_sprite(tx: Texture = null) -> void:
	if tx:
		texture = tx
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	elif _cursor_texture:
		texture = _cursor_texture
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	else:
		_hide_sprite()

func _hide_sprite() -> void:
	texture = null
	_set_position()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_FileMenu_sprite_showed() -> void:
	_show_sprite()

func _on_FileMenu_sprite_hided() -> void:
	_hide_sprite()

func _on_Elements_sprite_showed() -> void:
	_show_sprite()

func _on_Elements_sprite_hided() -> void:
	_hide_sprite()

func _on_LevelMenu_sprite_showed() -> void:
	_show_sprite()

func _on_LevelMenu_sprite_hided() -> void:
	_hide_sprite()

func _on_Objects_sprite_showed(texture: Texture = null) -> void:
	_show_sprite(texture)

func _on_Objects_sprite_hided() -> void:
	_hide_sprite()

func _on_Objects_sprite_texture_saved(
	texture: Texture, polygon: PoolVector2Array
) -> void:
	$Area2D/CollisionPolygon2D.polygon = polygon
	_cursor_texture = texture

func _on_Objects_sprite_texture_removed() -> void:
	$Area2D/CollisionPolygon2D.polygon = []
	_cursor_texture = null

func _on_Objects_sprite_position_updated(pos: Vector2) -> void:
	_set_position(pos)

func _on_Objects_cursor_shape_updated(shape: int) -> void:
	Input.set_default_cursor_shape(shape)
