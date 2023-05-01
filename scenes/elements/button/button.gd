extends Element

const _on: Texture2D = preload("res://scenes/elements/button/button_on.png")
const _off: Texture2D = preload("res://scenes/elements/button/button_off.png")
const _on_off: Texture2D = preload("res://scenes/elements/button/button_on_off.png")

var _is_activated: bool = false
var _delay: int = Globals.GAME.BUTTON_DELAY

func _ready() -> void:
	type = Globals.Elements.BUTTON
	super()

func reset_energy():
	_off_texture = self._off
	super()

func switch() -> void:
	_is_activated = !_is_activated

func _has_energy() -> bool:
	if $Connectors/In.connected_has_energy():
		if _is_activated:
			if _delay <= 0:
				_delay = Globals.GAME.BUTTON_DELAY
				switch()
			else:
				_delay-=1
			$Connectors/Out.set_energy(true)
			return true
		else:
			_off_texture = self._on_off
			return false
	return false


