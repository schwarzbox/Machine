extends Level

func _ready() -> void:
	$CanvasLayer/LevelMenu/Info/Label.hide()
	$CanvasLayer/LevelMenu/HideButton.hide()
	$CanvasLayer/LevelMenu.show_menu()
