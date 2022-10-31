extends Resource

class_name RelayDelayUtil

var time: int = 0
var switched: bool = false
var paused: bool = false
var saved_energy: bool = false

func _delay() -> bool:
	if not self.switched:
		self.time += 1
		if self.time >= Globals.GAME.FREQUENCY:
			self.switched = true
			return false
		return true
	else:
		self.time -= 1
		if self.time <= 0:
			self.switched = false
			return false
		return true

func _reset_time() -> void:
	self.time = 0

func reset() -> void:
	self._reset_time()
	self.switched = false
	self.paused = false
	self.saved_energy = false

func run(energy: bool) -> bool:
	if self.paused:
		self.paused = self._delay()
		if self.paused:
			return not self.saved_energy
		return energy

	if energy:
		if not self.switched:
			self.paused = true
			self.saved_energy = energy
	else:
		if self.switched:
			self.paused = true
			self.saved_energy = energy

	if self.paused:
		return not self.saved_energy
	return energy
