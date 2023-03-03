extends Level

func _ready() -> void:
	type = Globals.Levels.SETTINGS

	$CanvasLayer/LevelMenu/Info/Label.hide()
	$CanvasLayer/LevelMenu/HideButton.hide()
	$CanvasLayer/LevelMenu.show_menu()

	super._ready()
