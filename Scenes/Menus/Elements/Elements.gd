extends VBoxContainer

class_name Elements

var __elements_scenes = {
	"Wire": [
		load("res://Scenes/Elements/Wire/Wire.tscn"),
		preload("res://Scenes/Elements/Wire/wire_cursor_off.png")
	],
	"Battery": [
		load("res://Scenes/Elements/Battery/Battery.tscn"),
		preload("res://Scenes/Elements/Battery/battery.png")
	],
	"Lamp": [
		load("res://Scenes/Elements/Lamp/Lamp.tscn"),
		preload("res://Scenes/Elements/Lamp/lamp_off.png")
	],
	"Display": [
		load("res://Scenes/Elements/Display/Display.tscn"),
		preload("res://Scenes/Elements/Display/display_off.png")
	],
	"Switch": [
		load("res://Scenes/Elements/Switch/Switch.tscn"),
		preload("res://Scenes/Elements/Switch/switch_off.png")
	],
	"Relay": [
		load("res://Scenes/Elements/Relay/Relay.tscn"),
		preload("res://Scenes/Elements/Relay/relay_off.png")
	],
	"Power Relay": [
		load("res://Scenes/Elements/PowerRelay/PowerRelay.tscn"),
		preload("res://Scenes/Elements/PowerRelay/power_relay_off.png")
	],
	"Inverter": [
		load("res://Scenes/Elements/Inverter/Inverter.tscn"),
		preload("res://Scenes/Elements/Inverter/inverter_off.png")
	],
	"Power Inverter": [
		load("res://Scenes/Elements/PowerInverter/PowerInverter.tscn"),
		preload("res://Scenes/Elements/PowerInverter/power_inverter_off.png")
	],
	"And": [
		load("res://Scenes/Elements/And/And.tscn"),
		preload("res://Scenes/Elements/And/and_off.png")
	],
	"Or": [
		load("res://Scenes/Elements/Or/Or.tscn"),
		preload("res://Scenes/Elements/Or/or_off.png")
	],
	"Not And": [
		load("res://Scenes/Elements/NotAnd/NotAnd.tscn"),
		preload("res://Scenes/Elements/NotAnd/not_and_off.png")
	],
	"Not Or": [
		load("res://Scenes/Elements/NotOr/NotOr.tscn"),
		preload("res://Scenes/Elements/NotOr/not_or_off.png")
	],
	"Ex And": [
		load("res://Scenes/Elements/ExAnd/ExAnd.tscn"),
		preload("res://Scenes/Elements/ExAnd/ex_and_off.png")
	],
	"Ex Or": [
		load("res://Scenes/Elements/ExOr/ExOr.tscn"),
		preload("res://Scenes/Elements/ExOr/ex_or_off.png")
	],
	"Half Adder": [
		load("res://Scenes/Elements/HalfAdder/HalfAdder.tscn"),
		preload("res://Scenes/Elements/HalfAdder/half_adder_off.png")
	],
	"Full Adder": [
		load("res://Scenes/Elements/FullAdder/FullAdder.tscn"),
		preload("res://Scenes/Elements/FullAdder/full_adder_off.png")
	],
	"Adder 8 Bit": [
		load("res://Scenes/Elements/Adder8Bit/Adder8Bit.tscn"),
		preload("res://Scenes/Elements/Adder8Bit/adder_8_bit_off.png")
	]
}

var _on_mouse_entered: bool = false

signal button_pressed
signal sprite_showed
signal sprite_hided
signal element_added

func _ready() -> void:
	self._update_rect_size()

	# connect buttons
	for child in $GridContainer.get_children():
		child.connect(
			"pressed", self, "_on_Button_pressed",
			[
				child,
				__elements_scenes[child.name][0],
				__elements_scenes[child.name][1]
			]
		)

func _update_rect_size():
	self.rect_size = self.rect_min_size

func toogle(instance = null) -> void:
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

func _on_Button_pressed(
	instance: TextureButton, scene: PackedScene, icon: Texture
) -> void:

	self.toogle(instance)
	self.emit_signal("button_pressed", scene, icon, instance.pressed)

	if not self.is_mouse_entered():
		self.emit_signal("sprite_showed")

func _on_HideButton_pressed() -> void:
	if $GridContainer.visible:
		$GridContainer.hide()
	else:
		$GridContainer.show()

	self._update_rect_size()

func is_mouse_entered():
	return self._on_mouse_entered

func _on_Elements_mouse_entered() -> void:
	self._on_mouse_entered = true
	self.emit_signal("sprite_hided")

func _on_Elements_mouse_exited() -> void:
	self._on_mouse_entered = false
	self.emit_signal("sprite_showed")

func _on_Objects_scene_deselected() -> void:
	self.toogle()

func _on_Objects_clone_pressed(element: Element) -> void:
	var scene: PackedScene = (
		self.__elements_scenes[element.get_type_name()][0]
	)
	var clone = scene.instance()
	self.emit_signal("element_added", clone)

