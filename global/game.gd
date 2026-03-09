extends Node

var mus_time: float
var bpm: float = 120 :
	set(amount):
		bpm = amount
		crotchet = 60.0 / amount
		step_crotchet = crotchet / 4.0
var current_beat: int = 0 
var crotchet = 60.0 / bpm
var step_crotchet = crotchet / 4.0

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
