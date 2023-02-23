extends VBoxContainer

signal button_pressed
signal sprite_showed
signal sprite_hided
signal element_added

var _elements_scenes: Dictionary = {
	"Wire": [
		load("res://scenes/elements/wire/wire.tscn"),
		preload("res://scenes/elements/wire/wire_cursor_off.png")
	],
	"Battery": [
		load("res://scenes/elements/battery/battery.tscn"),
		preload("res://scenes/elements/battery/battery.png")
	],
	"Lamp": [
		load("res://scenes/elements/lamp/lamp.tscn"),
		preload("res://scenes/elements/lamp/lamp_off.png")
	],
	"Display": [
		load("res://scenes/elements/display/display.tscn"),
		preload("res://scenes/elements/display/display_off.png")
	],
	"Switch": [
		load("res://scenes/elements/switch/switch.tscn"),
		preload("res://scenes/elements/switch/switch_off.png")
	],
	"Relay": [
		load("res://scenes/elements/relay/relay.tscn"),
		preload("res://scenes/elements/relay/relay_off.png")
	],
	"Power Relay": [
		load("res://scenes/elements/power_relay/power_relay.tscn"),
		preload("res://scenes/elements/power_relay/power_relay_off.png")
	],
	"Inverter": [
		load("res://scenes/elements/inverter/inverter.tscn"),
		preload("res://scenes/elements/inverter/inverter_off.png")
	],
	"Power Inverter": [
		load("res://scenes/elements/power_inverter/power_inverter.tscn"),
		preload("res://scenes/elements/power_inverter/power_inverter_off.png")
	],
	"And": [
		load("res://scenes/elements/and/and.tscn"),
		preload("res://scenes/elements/and/and_off.png")
	],
	"Or": [
		load("res://scenes/elements/or/or.tscn"),
		preload("res://scenes/elements/or/or_off.png")
	],
	"Not And": [
		load("res://scenes/elements/not_and/not_and.tscn"),
		preload("res://scenes/elements/not_and/not_and_off.png")
	],
	"Not Or": [
		load("res://scenes/elements/not_or/not_or.tscn"),
		preload("res://scenes/elements/not_or/not_or_off.png")
	],
	"Ex And": [
		load("res://scenes/elements/ex_and/ex_and.tscn"),
		preload("res://scenes/elements/ex_and/ex_and_off.png")
	],
	"Ex Or": [
		load("res://scenes/elements/ex_or/ex_or.tscn"),
		preload("res://scenes/elements/ex_or/ex_or_off.png")
	],
	"Half Adder": [
		load("res://scenes/elements/half_adder/half_adder.tscn"),
		preload("res://scenes/elements/half_adder/half_adder_off.png")
	],
	"Full Adder": [
		load("res://scenes/elements/full_adder/full_adder.tscn"),
		preload("res://scenes/elements/full_adder/full_adder_off.png")
	],
	"Adder 8 Bit": [
		load("res://scenes/elements/adder_8_bit/adder_8_bit.tscn"),
		preload("res://scenes/elements/adder_8_bit/adder_8_bit_off.png")
	]
}

var _is_mouse_entered: bool = false

func _ready() -> void:
	_update_rect_size()
	# connect buttons
	for child in $GridContainer.get_children():
		child.connect(
			"pressed", self, "_on_Button_pressed",
			[
				child,
				_elements_scenes[child.name][0],
				_elements_scenes[child.name][1]
			]
		)

func _toogle(instance = null) -> void:
	for child in $GridContainer.get_children():
		if child != instance:
			child.pressed = false
			child.get_node("ColorRect").color = Globals.COLORS.DEFAULT_BUTTON

	if instance:
		var bg: ColorRect = instance.get_node("ColorRect")
		if instance.pressed:
			bg.color = Globals.COLORS.TOOGLE_BUTTON
		else:
			bg.color = Globals.COLORS.DEFAULT_BUTTON

func _update_rect_size():
	rect_size = rect_min_size

func _on_Button_pressed(
	instance: TextureButton, scene: PackedScene, icon: Texture
) -> void:

	_toogle(instance)
	emit_signal("button_pressed", scene, icon, instance.pressed)

	if !_is_mouse_entered:
		emit_signal("sprite_showed")

func _on_HideButton_pressed() -> void:
	if $GridContainer.visible:
		$GridContainer.hide()
	else:
		$GridContainer.show()
	_update_rect_size()

func _on_Elements_mouse_entered() -> void:
	_is_mouse_entered = true
	emit_signal("sprite_hided")

func _on_Elements_mouse_exited() -> void:
	_is_mouse_entered = false
	emit_signal("sprite_showed")

func _on_Objects_scene_deselected() -> void:
	_toogle()

func _on_Objects_clone_pressed(element: Element) -> void:
	var scene: PackedScene = (_elements_scenes[element.type_name][0])
	var clone: Element = scene.instance()
	emit_signal("element_added", clone)

