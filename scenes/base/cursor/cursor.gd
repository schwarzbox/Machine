extends Sprite

class_name Cursor

# maybe exists better solution
# to check when cursor in safe area
var type: int = -1

var _cursor_texture: Texture = null

func save_texture(texture: Texture) -> void:
	self._cursor_texture = texture

func remove_texture() -> void:
	self._cursor_texture = null

func show_sprite(texture: Texture = null) -> void:
	if texture:
		self.texture = texture
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	elif self._cursor_texture:
		self.texture = self._cursor_texture
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	else:
		self.hide_sprite()

func hide_sprite() -> void:
	self.texture = null
	self.set_position()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func set_position(pos: Vector2 = Vector2()) -> void:
	self.position = pos

func _on_FileMenu_sprite_showed() -> void:
	self.show_sprite()

func _on_FileMenu_sprite_hided() -> void:
	self.hide_sprite()

func _on_Elements_sprite_showed() -> void:
	self.show_sprite()

func _on_Elements_sprite_hided() -> void:
	self.hide_sprite()

func _on_LevelMenu_sprite_showed() -> void:
	self.show_sprite()

func _on_LevelMenu_sprite_hided() -> void:
	self.hide_sprite()

func _on_Objects_sprite_showed(texture: Texture = null) -> void:
	self.show_sprite(texture)

func _on_Objects_sprite_hided() -> void:
	self.hide_sprite()

func _on_Objects_sprite_texture_saved(texture: Texture, polygon: PoolVector2Array) -> void:
	$Area2D/CollisionPolygon2D.polygon = polygon
	self.save_texture(texture)

func _on_Objects_sprite_texture_removed() -> void:
	$Area2D/CollisionPolygon2D.polygon = []
	self.remove_texture()

func _on_Objects_sprite_position_updated(pos: Vector2) -> void:
	self.set_position(pos)


