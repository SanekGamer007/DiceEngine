extends Node

var mus_time: float = 0
var bpm: float = 120:
	set(amount):
		if bpm == amount:
			return
		bpm = amount
		crotchet = (60.0 / bpm) * (4.0 / denominator)
		step_crotchet = crotchet / 4.0
		bpm_changed.emit(bpm)
var current_beat: int = 0:
	set(i):
		if current_beat != i:
			beat.emit(i)
		current_beat = i
var current_measure: int = 0:
	set(i):
		if current_measure != i:
			measure.emit(i)
		current_measure = i
var crotchet: float = 4
var step_crotchet: float = 4

var numerator: int = 4:
	set(i):
		if numerator != i:
			numerator_changed.emit(i)
		numerator = i
var denominator: int = 4:
	set(i):
		if denominator != i:
			denominator_changed.emit(i)
		denominator = i

var seen_intro: bool = false
var last_played_song: String = ""

signal beat(count: int)
signal measure(measure: int)

signal bpm_changed(amount: int)
signal numerator_changed(numerator: int)
signal denominator_changed(denominator: int)


func _ready() -> void:
	var title = "Friday Night Funkin' " + Common.engine_name + " v" + Common.get_version()
	if OS.is_debug_build():
		title += " (DEBUG)"
	await get_tree().process_frame
	DisplayServer.window_set_title(title)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("fullscreen"):
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
