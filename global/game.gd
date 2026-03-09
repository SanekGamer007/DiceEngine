extends Node

var mus_time: float
var bpm: float = 120 :
	set(amount):
		if bpm == amount:
			return
		bpm = amount
		crotchet = 60.0 / amount
		step_crotchet = crotchet / 4.0
		bpm_changed.emit(bpm)
var current_beat: int = 0 :
	set(i):
		if current_beat != i:
			beat.emit(i)
		current_beat = i
var crotchet = 60.0 / bpm
var step_crotchet = crotchet / 4.0

signal beat(count: int)
signal bpm_changed(amount: int)

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
