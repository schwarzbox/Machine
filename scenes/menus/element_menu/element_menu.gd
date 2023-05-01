extends VBoxContainer

# Elements
signal button_pressed
signal element_added
# Cursor
signal sprite_hided
signal sprite_showed

var _elements_scenes: Dictionary = {
	"Wire": [
		preload("res://scenes/elements/wire/wire.tscn"),
		preload("res://scenes/elements/wire/wire_cursor_off.png")
	],
	"Battery": [
		preload("res://scenes/elements/battery/battery.tscn"),
		preload("res://scenes/elements/battery/battery.png")
	],
	"Lamp": [
		preload("res://scenes/elements/lamp/lamp.tscn"),
		preload("res://scenes/elements/lamp/lamp_off.png")
	],
	"Display": [
		preload("res://scenes/elements/display/display.tscn"),
		preload("res://scenes/elements/display/display_off.png")
	],
	"Switch": [
		preload("res://scenes/elements/switch/switch.tscn"),
		preload("res://scenes/elements/switch/switch_off.png")
	],
	"Button": [
		preload("res://scenes/elements/button/button.tscn"),
		preload("res://scenes/elements/button/button_off.png")
	],
	"Relay": [
		preload("res://scenes/elements/relay/relay.tscn"),
		preload("res://scenes/elements/relay/relay_off.png")
	],
	"Power Relay": [
		preload("res://scenes/elements/power_relay/power_relay.tscn"),
		preload("res://scenes/elements/power_relay/power_relay_off.png")
	],
	"Inverter": [
		preload("res://scenes/elements/inverter/inverter.tscn"),
		preload("res://scenes/elements/inverter/inverter_off.png")
	],
	"Power Inverter": [
		preload("res://scenes/elements/power_inverter/power_inverter.tscn"),
		preload("res://scenes/elements/power_inverter/power_inverter_off.png")
	],
	"And": [
		preload("res://scenes/elements/and/and.tscn"),
		preload("res://scenes/elements/and/and_off.png")
	],
	"Or": [
		preload("res://scenes/elements/or/or.tscn"),
		preload("res://scenes/elements/or/or_off.png")
	],
	"Not And": [
		preload("res://scenes/elements/not_and/not_and.tscn"),
		preload("res://scenes/elements/not_and/not_and_off.png")
	],
	"Not Or": [
		preload("res://scenes/elements/not_or/not_or.tscn"),
		preload("res://scenes/elements/not_or/not_or_off.png")
	],
	"Ex And": [
		preload("res://scenes/elements/ex_and/ex_and.tscn"),
		preload("res://scenes/elements/ex_and/ex_and_off.png")
	],
	"Ex Or": [
		preload("res://scenes/elements/ex_or/ex_or.tscn"),
		preload("res://scenes/elements/ex_or/ex_or_off.png")
	],
	"Half Adder": [
		preload("res://scenes/elements/half_adder/half_adder.tscn"),
		preload("res://scenes/elements/half_adder/half_adder_off.png")
	],
	"Full Adder": [
		preload("res://scenes/elements/full_adder/full_adder.tscn"),
		preload("res://scenes/elements/full_adder/full_adder_off.png")
	],
	"Selector": [
		preload("res://scenes/elements/selector/selector.tscn"),
		preload("res://scenes/elements/selector/selector_off.png")
	],
	"Trigger Reset": [
		preload("res://scenes/elements/trigger_reset/trigger_reset.tscn"),
		preload("res://scenes/elements/trigger_reset/trigger_reset_off.png")
	],
	"Trigger Level": [
		preload("res://scenes/elements/trigger_level/trigger_level.tscn"),
		preload("res://scenes/elements/trigger_level/trigger_level_off.png")
	],
	"Trigger Level Reset": [
		preload("res://scenes/elements/trigger_level_reset/trigger_level_reset.tscn"),
		preload("res://scenes/elements/trigger_level_reset/trigger_level_reset_off.png")
	],
	"Trigger Front": [
		preload("res://scenes/elements/trigger_front/trigger_front.tscn"),
		preload("res://scenes/elements/trigger_front/trigger_front_off.png")
	]
}

var _is_mouse_entered: bool = false

func _ready() -> void:
	_update_rect_size()
	# connect buttons
	for child in $GridContainer.get_children():
		child.connect(
			"pressed",
			Callable(self, "_on_element_button_pressed").bind(
				child,
				_elements_scenes[child.name][0],
				_elements_scenes[child.name][1]
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
		$GridContainer.hide()
	else:
		$GridContainer.show()
	_update_rect_size()

func _on_elements_scene_deselected() -> void:
	_toogle()

func _on_elements_clone_pressed(element: Element) -> void:
	var scene: PackedScene = (_elements_scenes[element.type_name][0])
	var clone: Element = scene.instantiate()
	emit_signal("element_added", clone)
