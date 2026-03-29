extends Control

@export var song_name: String
@export var notes: Array[Dictionary]
@export var difficulty: Common.DIFFICULTY = Common.DIFFICULTY.HARD
@export var difficulty_string: String
var BPM: int = 120

signal loading_complete

func _ready() -> void:
	difficulty_string = Common.difficulty_to_string(difficulty)
	var song_chart_location = "res://assets/songs/" + song_name + "/" + song_name + ".json"
	$AudioPlayers/AudioStreamPlayerInst.stream = load("res://assets/songs/" + song_name + "/song/Inst.ogg")
	
	var voices: Dictionary[int, String] = {} # id -> filepath
	var voice_file_names = DirAccess.get_files_at("res://assets/songs/" + song_name + "/song/")
	for i: String in voice_file_names:
		if i.ends_with(".ogg") and not i.contains(".import") and not i.contains("Inst"):
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
		loading_complete.connect(strumline._on_loading_complete)
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
	
	if FileAccess.file_exists(song_chart_location):
		var file = FileAccess.open(song_chart_location, FileAccess.READ)
		var chart_file = file.get_as_text()
		var chart_data: Dictionary = JSON.parse_string(chart_file)
		var meta_data: Dictionary = chart_data.get("metadata", {})
		var all_diffs: Dictionary = chart_data.get("chart")
		var diff_chart = all_diffs.get(difficulty_string)
		var diff_scroll_speed = diff_chart.get("scrollspeed")
		var diff_notes: Array[Dictionary]
		diff_notes.assign(diff_chart.get("notes"))
		
		BPM = diff_chart.get("bpm", 120)
		
		#var stage_name = meta_data.get("stage", "mainStage")
		#var stagepacked: PackedScene = load(Registry.stages.get("main_stage"))
		#var stage: Node2D = stagepacked.instantiate()
		#add_child(stage)
		#move_child(stage, 0)
		diff_notes.sort_custom(func(a, b): return a.t < b.t)
		notes = diff_notes
		for strumline: StrumLine in $StrumLines.get_children():
			strumline.scroll_speed = diff_scroll_speed
			for note: Dictionary in notes:
				if note.s == strumline.id:
					strumline.notes.append(note)
	loading_complete.emit()

func _process(delta: float) -> void:
	if $AudioPlayers/AudioStreamPlayerInst.playing == false:
		Game.mus_time += delta
	else:
		Game.mus_time = $AudioPlayers/AudioStreamPlayerInst.get_playback_position()
