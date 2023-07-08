class_name RelayDelayUtil

extends RefCounted

var _time: int = 0
var _is_switched: bool = false
var _is_paused: bool = false
var _saved_energy: bool = false

func reset() -> void:
	_time = 0
	_is_switched = false
	_is_paused = false
	_saved_energy = false

func run(energy: bool) -> bool:
	if _is_paused:
		_is_paused = _delay()
		if _is_paused:
			return !_saved_energy
		return energy

	if energy:
		if !_is_switched:
			_is_paused = true
			_saved_energy = energy
	else:
		if _is_switched:
			_is_paused = true
			_saved_energy = energy

	if _is_paused:
		return !_saved_energy
	return energy

func _delay() -> bool:
	if !_is_switched:
		_time += 1
		if _time >= Globals.GAME.FREQUENCY:
			_is_switched = true
			return false
		return true
	else:
		_time -= 1
		if _time <= 0:
			_is_switched = false
			return false
		return true

