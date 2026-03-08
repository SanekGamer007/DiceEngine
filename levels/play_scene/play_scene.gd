extends Node2D

@export var song_name: String
@export var difficulty: Common.DIFFICULTY = Common.DIFFICULTY.HARD
var notes: Array[Dictionary]
var difficulty_string: String

var stage: Node2D
var strumlines: Array[StrumLine]
var characters: Array[Character]
var scroll_speed: float = 0.0

var last_audio_pos: float = 0.0

const STRUMLINE_PRELOAD: PackedScene = preload("res://objects/strum_line/strum_line.tscn")

signal notes_loaded

func _ready() -> void:
	set_process(false)
	notes_loaded.connect($ui._init_done)
	var song_chart_location = "res://assets/songs/" + song_name + "/" + song_name + ".json"
	difficulty_string = Common.difficulty_to_string(difficulty)
	var chart: Dictionary
	if FileAccess.file_exists(song_chart_location):
		chart = load_chart_file(song_chart_location)
	else:
		push_error("FATAL: Chart file not found.")
		return
	
	var metadata: Dictionary = chart.get("metadata", {})
	var all_diffs: Dictionary = chart.get("chart")
	if not metadata:
		push_error("FATAL: Chart file is invalid.\nINFO: Metadata section not found.")
		return
	if not all_diffs:
		push_error("FATAL: Chart file is invalid.\nINFO: Chart section not found.")
		return
	
	var diff_chart: Dictionary = all_diffs.get(difficulty_string)
	scroll_speed = diff_chart.get("scrollspeed")
	if not diff_chart:
		push_error("FATAL: Chart file is invalid.\nINFO: Chart for selected difficulty wasn't found.")
		return
	if not scroll_speed:
		push_error("FATAL: Chart file is invalid.\nINFO: Scroll speed for selected difficulty wasn't found.")
		return
	var diff_notes: Array[Dictionary]
	diff_notes.assign(diff_chart.get("notes", [])) # ew json sucks.
	diff_notes.sort_custom(func(a, b): return a.t < b.t)
	notes = diff_notes
	var strumlines_to_spawn: int = 0
	for i in notes:
		if i.s + 1 > strumlines_to_spawn:
			strumlines_to_spawn = i.s + 1
			continue
	spawn_strumlines(strumlines_to_spawn)
	
	if not metadata.has("stage"):
		push_warning('WARN: Stage not found in chart\nINFO: Using the default "main_stage" stage.')
	var stage_name = metadata.get("stage", "main_stage")
	load_stage(stage_name)
	
	Game.bpm = diff_chart.get("bpm", 120)
	if not diff_chart.has("bpm"):
		push_warning("WARN: BPM Not found in chart.\nINFO: Using the default of 120.")
	
	if not metadata.has("chars"):
		push_error("ERROR: Character information not found in chart.\nINFO: Spawning no characters.")
	else:
		var chars: Dictionary = metadata.get("chars", {})
		spawn_chars(chars)
	
	for strumline_idx in strumlines.size():
		var strumline: StrumLine = strumlines[strumline_idx]
		for character: Character in characters:
			if strumline.character:
				continue
			if character.id == strumline.id:
				strumline.character = character
				print("Line ", strumline.id, " Found ", character.id, " / ", character.get_index())
				continue
			if character.get_index() == strumline_idx:
				print("Line ", strumline.id, " Found ", character.id, " / ", character.get_index())
				strumline.character = character
				continue

	spawn_music()
	set_process(true)
	notes_loaded.emit()

func _process(delta: float) -> void:
	var player: AudioStreamPlayer = $AudioPlayers/AudioStreamPlayerInst
	if player.playing:
		var current_audio_pos = player.get_playback_position()
		
		if current_audio_pos != last_audio_pos:
			Game.mus_time = current_audio_pos + AudioServer.get_time_since_last_mix() - AudioServer.get_output_latency()
			last_audio_pos = current_audio_pos
		else:
			Game.mus_time += delta
	else:
		Game.mus_time += delta


func load_chart_file(location: String) -> Dictionary:
	var file = FileAccess.open(location, FileAccess.READ)
	var chart_file = file.get_as_text()
	return JSON.parse_string(chart_file)

func load_stage(stage_name: String) -> void:
	var stagepacked: PackedScene = load("res://assets/stages/" + stage_name + "/stage.tscn")
	stage = stagepacked.instantiate()
	add_child(stage)
	move_child(stage, 0)

func spawn_strumlines(amount: int) -> void:
	var markers = $StrumLines.get_children()
	for i in range(amount):
		var strumline: StrumLine = STRUMLINE_PRELOAD.instantiate()
		var marker: Marker2D = markers.get(i)
		strumline.global_position = marker.global_position
		strumline.id = i
		if i == 0:
			strumline.bot_play = false
		else:
			strumline.bot_play = true
		strumline.ghost_tapping = true # temporary.
		strumline.scroll_speed = scroll_speed
		notes_loaded.connect(strumline._on_notes_loaded)
		for note: Dictionary in notes:
				if note.s == strumline.id:
					strumline.notes.append(note)
		$StrumLines.add_child(strumline, true)
		strumlines.append(strumline)
	for marker: Marker2D in markers:
		marker.queue_free()

func spawn_music() -> void:
	var voices: Dictionary[int, String] = {} # id -> filepath
	var inst: String
	var file_names = DirAccess.get_files_at("res://assets/songs/" + song_name + "/song/")
	for i: String in file_names:
		if i.ends_with(".ogg") and not i.contains(".import"):
			if i.contains("Inst"):
				inst = "res://assets/songs/" + song_name + "/song/" + i
				continue
			var id = i.trim_prefix("Voices-id").trim_suffix(".ogg")
			voices[int(id)] = "res://assets/songs/" + song_name + "/song/" + i
	if inst:
		$AudioPlayers/AudioStreamPlayerInst.stream = load(inst)
		$AudioPlayers/AudioStreamPlayerInst.play()
	else:
		push_error("ERROR: Instumentals not found for song", song_name, ".")
	if voices.size() <= 0:
		push_warning("WARN: No vocals found for song", song_name, ".")
	for i in voices.keys():
		var player: AudioStreamPlayer = AudioStreamPlayer.new()
		player.name = "AudioStreamPlayerID" + str(i)
		player.stream = load(voices[i])
		$AudioPlayers.add_child(player)
		player.play()

func spawn_chars(chars: Dictionary) -> void:
	for i in chars.size():
		var char_name = chars.get(str(i))
		var markers: Array = stage.get_node("Markers").get_children()
		var marker: CharacterMarker2D
		for child: CharacterMarker2D in markers:
			if child.name.contains(str(i)):
				marker = child
				break
			else:
				continue
		if not FileAccess.file_exists("res://assets/characters/" + char_name + "/" + char_name + ".tscn"):
			push_error("FATAL: ", char_name, " Character not found.")
			continue
		var char_packed: PackedScene = load("res://assets/characters/" + char_name + "/" + char_name + ".tscn")
		var character: Character = char_packed.instantiate()
		var character_size = character.get_node("ReferenceRect").size
		var new_position = Vector2(marker.global_position.x, marker.global_position.y - character_size.y / 2)
		character.global_position = new_position
		character.flip_h = marker.flip_h
		character.flip_v = marker.flip_v
		$Characters.add_child(character, true)
		characters.append(character)
