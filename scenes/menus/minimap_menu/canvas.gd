extends Node2D

var icons: Array[Rect2] = []
var frame: Rect2 = Rect2()
var marker: Rect2 = Rect2()
var is_marker_visible: bool = false

func _ready() -> void:
	prints(name, "ready")

func _draw() -> void:
	for icon in icons:
		draw_rect(icon, Globals.COLORS.ENERGY_ON)

	draw_rect(frame, Globals.COLORS.OUTLINE, false)

	if is_marker_visible:
		draw_rect(marker, Globals.COLORS.OUTLINE, true)

