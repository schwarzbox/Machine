extends Node

# Elements and ELEMENT_SCENES
enum Elements {
	NONE,
	BATTERY,
	DISPLAY,
	INVERTER,
	LAMP,
	POWER_INVERTER,
	POWER_RELAY,
	RELAY,
	SWITCH,
	WIRE,
	AND,
	OR,
	NOT_AND,
	NOT_OR,
	EX_AND,
	EX_OR,
	HALF_ADDER,
	FULL_ADDER,
	BUTTON,
	SELECTOR,
	RESET_SET_FLIP_FLOP,
	LEVEL_FLIP_FLOP,
	LEVEL_FLIP_FLOP_WITH_RESET,
	EDGE_FLIP_FLOP,
	RAM_8_BIT,
	DECODER,
	RAM_256_BIT,
}

enum Connectors {
	NONE, IN, OUT
}

enum Levels {
	NONE, TUTORIAL, CAMPAIGN, SANDBOX, SETTINGS
}

enum Directions {NONE, HORIZONTAL, VERTICAL}

const COLORS: Dictionary = {
	ENERGY_ON = Color("#FDDF19"),
	ENERGY_OFF = Color("#C0CAD8"),
	OUTLINE = Color("#EEEEEE"),
	TOOGLE_BUTTON = Color("#333333"),
	DEFAULT_BUTTON = Color("#555555"),
	SAFE_AREA_ALARM = Color("#CE2E59"),
	WIRE_ALPHA = 0.5
}

const FONTS: Dictionary = {
	DEFAULT_FONT_SIZE = 24,
	MENU_LABEL_FINT_SIZE = 26,
	COLOR_LABEL_FONT_SIZE = 28,
	TITLE_FONT_SIZE = 64,
}

const GAME: Dictionary = {
	CURSOR_TYPE = -1,
	MAXIMUM_ELEMENTS_TO_SELECT = 2048,
	FREQUENCY = 4,
	BUTTON_DELAY = 8,
	MINIMAL_WIRE_LENGTH = 16,
	CONNECTED_WIRE_LENGTH = 512,
	REPULSE_WIRE_LENGTH = 64,
	DEFAULT_FILE_NAME = "untitled",
	NOTIFICATION_DELAY = 4,
	FILE_EXTENSION = "machine",
	SAVE_GAME_DIR = "user://",
	LAST_FILE = ".last_file",
}

const MINIMAP: Dictionary = {
	SCALE = 4,
	MARKER_SIZE = 16
}

const CAMERA: Dictionary = {
	ZOOM_MIN = 0.15,
	ZOOM_MAX = 1.0,
	PAN_SPEED = 8.0,
	DRAG_SPEED = 1.5
}

const ELEMENT_SCENES: Dictionary = {
	"Wire": [
		preload("res://scenes/elements/wire/wire.tscn"),
		preload("res://scenes/elements/wire/wire_cursor_off.png"),
		preload("res://scenes/elements/wire/wire_cursor_on.png")
	],
	"Battery": [
		preload("res://scenes/elements/battery/battery.tscn"),
		preload("res://scenes/elements/battery/battery_on.png")
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
	"Reset Set Flip Flop": [
		preload("res://scenes/elements/trigger_reset/trigger_reset.tscn"),
		preload("res://scenes/elements/trigger_reset/trigger_reset_off.png")
	],
	"Level Flip Flop": [
		preload("res://scenes/elements/trigger_level/trigger_level.tscn"),
		preload("res://scenes/elements/trigger_level/trigger_level_off.png")
	],
	"Level Flip Flop with Reset": [
		preload("res://scenes/elements/trigger_level_reset/trigger_level_reset.tscn"),
		preload("res://scenes/elements/trigger_level_reset/trigger_level_reset_off.png")
	],
	"Edge Flip Flop": [
		preload("res://scenes/elements/trigger_front/trigger_front.tscn"),
		preload("res://scenes/elements/trigger_front/trigger_front_off.png")
	],
	"Ram 8 Bit": [
		preload("res://scenes/elements/ram_8_bit/ram_8_bit.tscn"),
		preload("res://scenes/elements/ram_8_bit/ram_8_bit_off.png")
	],
	"Decoder": [
		preload("res://scenes/elements/decoder/decoder.tscn"),
		preload("res://scenes/elements/decoder/decoder_off.png")
	],
	"Ram 256 Bit": [
		preload("res://scenes/elements/ram_256_bit/ram_256_bit.tscn"),
		preload("res://scenes/elements/ram_256_bit/ram_256_bit_off.png")
	],
}
