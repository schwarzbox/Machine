extends Node

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
	ADDER_8_BIT
}

enum Connectors {
	NONE, IN, OUT
}

enum Levels {
	NONE, CAMPAIGN, SANDBOX, SETTINGS
}

const COLORS: Dictionary = {
	ENERGY_ON = Color("#ffff66"),
	ENERGY_OFF = Color("#99ccff"),
	OUTLINE = Color("#88ff88"),
	TOOGLE_BUTTON = Color("#333333"),
	DEFAULT_BUTTON = Color("#555555"),
	SAFE_AREA_ALARM = Color("#c96d3d")
}

const FONTS: Dictionary = {
	LABEL_FONT_SIZE = 24,
	MENU_FONT_SIZE = 24,
}

const GAME: Dictionary = {
	CURSOR_TYPE = -1,
	MAXIMUM_ELEMENTS_TO_SELECT = 2048,
	FREQUENCY = 4,
	MINIMAL_WIRE_LENGTH = 8,
	CONNECTED_WIRE_LENGTH = 128,
	REPULSE_WIRE_LENGTH = 32,
	UNSELECTED_ALPHA = 0.7,
	DEFAULT_FILE_NAME = "untitled",
	FILE_EXTENSION = "machine",
	SAVE_GAME_DIR = "user://",
	LAST_FILE = ".last_file"
}

const CAMERA: Dictionary = {
	ZOOM_MAX = 4.0,
	PAN_SPEED = 8.0,
	DRAG_SPEED = 1.5
}
