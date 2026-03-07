extends Control

@export var song_name: String
@export var notes: Array[Dictionary]
@export var difficulty: Common.DIFFICULTY = Common.DIFFICULTY.HARD
@export var difficulty_string: String

var mus_time: float
var BPM: int = 120

signal notes_loaded

func _ready() -> void:
	difficulty_string = Common.difficulty_to_string(difficulty)
	var chart_data: Dictionary
	var song_chart_location = "res://assets/songs/" + song_name + "/" + song_name + "-chart.json"
	var song_metadata_location = "res://assets/songs/" + song_name + "/" + song_name + "-metadata.json"
	$AudioPlayers/AudioStreamPlayerInst.stream = load("res://assets/songs/" + song_name + "/song/Inst.ogg")
	
	var voices: Dictionary[int, String] = {} # id -> filepath
	var voice_file_names = DirAccess.get_files_at("res://assets/songs/" + song_name + "/song/")
	for i: String in voice_file_names:
		if i.ends_with(".ogg") and not i.contains(".import"):
			var id = i.trim_prefix("Voices-id").trim_suffix(".ogg")
			voices[int(id)] = "res://assets/songs/" + song_name + "/song/" + i
	for i in voices.size():
		var player: AudioStreamPlayer = AudioStreamPlayer.new()
		player.name = "AudioStreamPlayerID" + str(i)
		player.stream = load(voices.get(i))
		$AudioPlayers.add_child(player)
		player.play()
	$AudioPlayers/AudioStreamPlayerInst.play()
	
	for strumline_idx: int in $StrumLines.get_child_count():
		var strumline: StrumLine = $StrumLines.get_child(strumline_idx)
		notes_loaded.connect(strumline._on_notes_loaded)
		for character: Character in $Characters.get_children():
			if strumline.character:
				break
			
			if character.id == strumline.id:
				strumline.character = character
				print("Line ", strumline.id, " Found ", character.id, " / ", character.get_index())
				break
			
			if character.get_index() == strumline_idx:
				print("Line ", strumline.id, " Found ", character.id, " / ", character.get_index())
				strumline.character = character
				break
	
	print("res://assets/stages/" + song_name + "/stage.tscn")
	if FileAccess.file_exists("res://assets/stages/" + song_name + "/stage.tscn"):
		var stagepacked: PackedScene = load("res://assets/stages/" + song_name + "/stage.tscn")
		var stage: Node2D = stagepacked.instantiate()
		add_child(stage)
		move_child(stage, 0)
	
	if FileAccess.file_exists(song_metadata_location):
		var file = FileAccess.open(song_metadata_location, FileAccess.READ)
		var metadata_file = file.get_as_text()
		var metadata = JSON.parse_string(metadata_file)
		var time_changes: Dictionary = metadata.get("timeChanges")[0]
		BPM = time_changes.get("bpm")
	if FileAccess.file_exists(song_chart_location):
		var file = FileAccess.open(song_chart_location, FileAccess.READ)
		var chart = file.get_as_text()
		chart_data = JSON.parse_string(chart)
		var all_notes: Dictionary = chart_data.get("notes")
		var all_scroll_speeds = chart_data.get("scrollSpeed")
		var diff_scroll_speed = all_scroll_speeds.get(difficulty_string)
		print(diff_scroll_speed)
		var diff_notes = all_notes.get(difficulty_string)
		for note: Dictionary in diff_notes:
			var id: int = int(note.d) % 4
			var strum: int = floori(note.d / 4)
			
			notes.append({
				"strum": strum,
				"id": id,
				"time": note.t / 1000.0,
			})
		notes.sort_custom(func(a, b): return a.time < b.time)
		for strumline: StrumLine in $StrumLines.get_children():
			strumline.scroll_speed = diff_scroll_speed
			for note: Dictionary in notes:
				if note.strum == strumline.id:
					strumline.notes.append(note)
	notes_loaded.emit()

func _process(delta: float) -> void:
	if $AudioPlayers/AudioStreamPlayerInst.playing == false:
		mus_time += delta
	else:
		mus_time = $AudioPlayers/AudioStreamPlayerInst.get_playback_position()
	for strumline: StrumLine in $StrumLines.get_children():
		strumline.mus_time = mus_time
