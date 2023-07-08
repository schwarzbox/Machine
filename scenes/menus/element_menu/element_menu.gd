extends VBoxContainer

# Elements
signal button_pressed
# Cursor
signal sprite_hided
signal sprite_showed

var _is_mouse_entered: bool = false

func _ready() -> void:
	_show_menu()

	# connect buttons
	for child in $GridContainer.get_children():
		child.connect(
			"pressed",
			Callable(self, "_on_element_button_pressed").bind(
				child,
				Globals.ELEMENT_SCENES[child.name][0],
				Globals.ELEMENT_SCENES[child.name][1]
			)
		)

	for node in [$HideButton]:
		node.add_theme_font_size_override(
			"font_size", Globals.FONTS.DEFAULT_FONT_SIZE
		)

func _toogle(instance = null) -> void:
	for child in $GridContainer.get_children():
		if child != instance:
			child.button_pressed = false
			child.get_node(^"ColorRect").color = Globals.COLORS.DEFAULT_BUTTON

	if instance:
		var panel: ColorRect = instance.get_node(^"ColorRect")
		if instance.button_pressed:
			panel.color = Globals.COLORS.TOOGLE_BUTTON
		else:
			panel.color = Globals.COLORS.DEFAULT_BUTTON

func _show_menu():
	$GridContainer.show()
	_update_rect_size()

func _hide_menu():
	$GridContainer.hide()
	_update_rect_size()

func _update_rect_size():
	size = custom_minimum_size

func _on_mouse_entered() -> void:
	_is_mouse_entered = true
	emit_signal("sprite_hided")

func _on_mouse_exited() -> void:
	_is_mouse_entered = false
	emit_signal("sprite_showed")

func _on_element_button_pressed(
	instance: TextureButton, scene: PackedScene, icon: Texture2D
) -> void:

	_toogle(instance)

	emit_signal("button_pressed", scene, icon, instance.button_pressed)

	if !_is_mouse_entered:
		emit_signal("sprite_showed")

func _on_hide_button_pressed() -> void:
	if $GridContainer.visible:
		_hide_menu()
	else:
		_show_menu()

func _on_elements_scene_deselected() -> void:
	_toogle()
