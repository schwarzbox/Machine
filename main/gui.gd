extends CenterContainer

signal button1_pressed
signal button2_pressed
signal button3_pressed
signal button4_pressed

func _ready() -> void:
	prints(name, "ready")

func _on_Button1_pressed() -> void:
	emit_signal("button1_pressed")

func _on_Button2_pressed() -> void:
	emit_signal("button2_pressed")

func _on_Button3_pressed() -> void:
	emit_signal("button3_pressed")

func _on_Button4_pressed() -> void:
	emit_signal("button4_pressed")

