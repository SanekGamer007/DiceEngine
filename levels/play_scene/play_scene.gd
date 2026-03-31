extends Node2D
class_name PlayScene

@export var song_name: String
@export var difficulty: String
@export var note_skin: NoteSkinResource

const STRUMLINE_PRELOAD: PackedScene = preload("res://objects/strum_line/strum_line.tscn")

var song_chart: Dictionary = {}
var song_metadata: Dictionary = {}

var notes: Array[Dictionary]
var scroll_speed: float = 0.0
var last_audio_pos: float = 0.0

var min_hp: float = 0.0
var hp: float = 50.0 :
	set(amount):
		amount = clampf(amount, min_hp, max_hp)
		hp = amount
		_update_hp()
var max_hp: float = 100.0

var hp_gain_player_hit: float = 2.5
var hp_gain_player_sustain: float = 0.25
var hp_loss_player_miss: float = 5
var hp_gain_opponent_hit: float = 0
var hp_gain_opponent_sustain: float = 0
var hp_loss_opponent_hit: float = 2
var hp_loss_opponent_sustain: float = 0.2
var hp_loss_opponent_cap: float = 20

enum STATES {
	LOADING,
	COUNTDOWN,
	PLAYING,
	PAUSED,
	ENDING,
	DEAD,
}

var state: STATES = STATES.LOADING

signal loading_complete


func _ready() -> void:
	state = STATES.LOADING
	Refs.clear()
	loading_complete.connect($Hud._init_done)
	Refs.play_scene = self
	Refs.hud = $Hud
	spawn_ui()
	$Hud.play_scene = self
	if not Registry.songs.has(song_name):
		push_error("Song not found.")
		return
	var song_all_info: Dictionary = Registry.songs.get(song_name)
	
	song_chart = song_all_info.get(difficulty, {})
	var chart: Dictionary
	if FileAccess.file_exists(song_chart.get("chart", "")):
		chart = load_chart_file(song_chart.get("chart"))
	else:
		push_error("Chart file not found.")
		return
	song_metadata = chart.get("metadata", {})
	var all_diffs: Dictionary = chart.get("chart")
	if not song_metadata:
		push_error("Chart file is invalid, metadata section not found.")
		return
	if not all_diffs:
		push_error("Chart file is invalid, chart section not found.")
		return
	
	var diff_chart: Dictionary = all_diffs.get(difficulty, {})
	scroll_speed = diff_chart.get("scrollspeed", 0.0)
	if not diff_chart:
		push_error("Chart file is invalid, chart for selected difficulty wasn't found.")
		return
	if not scroll_speed:
		push_error("Chart file is invalid, scroll speed for selected difficulty wasn't found.")
		return
	var diff_notes: Array[Dictionary]
	diff_notes.assign(diff_chart.get("notes", [])) # ew json sucks.
	diff_notes.sort_custom(func(a, b): return a.t < b.t)
	notes = diff_notes
	spawn_strumlines()
	
	if not song_metadata.has("stage"):
		push_warning('Stage not found in chart, using the default "main_stage" stage.')
	var stage_name = song_metadata.get("stage", "main_stage")
	load_stage(stage_name)
	
	Game.bpm = diff_chart.get("bpm", 120)
	if not diff_chart.has("bpm"):
		push_warning("BPM Not found in chart, using the default of 120.")
	
	if not song_metadata.has("chars"):
		push_error("Character information not found in chart, spawning no characters.")
	else:
		var chars: Dictionary = song_metadata.get("chars", {})
		spawn_chars(chars)
	
	for strumline_idx in Refs.strumlines.size():
		var strumline: StrumLine = Refs.strumlines[strumline_idx]
		for character: Character in Refs.characters:
			if strumline.character:
				continue
			if character.get_index() == strumline_idx:
				print("Line ", strumline.id, " Found ", character.get_index())
				strumline.character = character
				continue
		if not strumline.bot_play:
			strumline.note_pressed.connect(_on_player_note_hit)
			strumline.note_sustained.connect(_on_player_note_sustain)
			strumline.note_missed.connect(_on_player_note_miss)
		else:
			strumline.note_sustained.connect(_on_opponent_note_sustain)
			strumline.note_pressed.connect(_on_opponent_note_hit)
			
	for i in Refs.characters.size():
		if i == 0:
			Refs.hud.hp_bar.right_icon = Refs.characters[i].icon.instantiate()
			continue
		elif i == 1:
			Refs.hud.hp_bar.left_icon = Refs.characters[i].icon.instantiate()
			Refs.hud.hp_bar.right_icon.flip_h = true
			break
	spawn_music()
	loading_complete.emit()
	Game.mus_time = -3
	set_state(STATES.COUNTDOWN)


func _process(delta: float) -> void:
	match state:
		STATES.LOADING:
			_handle_loading_state()
		STATES.COUNTDOWN:
			_handle_countdown_state(delta)
		STATES.PLAYING:
			_handle_playing_state(delta)
		STATES.PAUSED:
			_handle_paused_state()
		STATES.ENDING:
			_handle_ending_state()
		STATES.DEAD:
			_handle_dead_state()
	Game.current_beat = floor(Game.mus_time / Game.crotchet)
	var new_measure = floori(Game.current_beat / Game.numerator)
	if new_measure != Game.current_measure:
		Game.current_measure = new_measure
	if hp <= min_hp:
		set_state(STATES.DEAD)

func _handle_loading_state() -> void:
	pass


func _handle_countdown_state(delta: float) -> void:
	if Game.mus_time >= 0:
		set_state(STATES.PLAYING)
		return
	Game.mus_time += delta


func _handle_playing_state(delta: float) -> void:
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
	if notes.is_empty():
		if not player.playing:
			set_state(STATES.ENDING)
	if Game.mus_time >= notes[-1].t + 3:
		set_state(STATES.ENDING)


func _handle_paused_state() -> void:
	pass


func _handle_ending_state() -> void:
	pass


func _handle_dead_state() -> void:
	pass


func set_state(new_state: STATES) -> void:
	if new_state == STATES.PLAYING:
		for player: AudioStreamPlayer in $AudioPlayers.get_children():
			player.play(0.0)
	elif new_state == STATES.DEAD:
		for player: AudioStreamPlayer in $AudioPlayers.get_children():
			player.stop()
		Refs.clear()
		set_process(false)
		TransitionManager.change_scene_to_file(Registry.menus.get("freeplay_proto"), "fade", 1.0)
		return
	elif new_state == STATES.ENDING:
		Refs.clear()
		set_process(false)
		TransitionManager.change_scene_to_file(Registry.menus.get("freeplay_proto"), "fade", 1.0)
		return
	state = new_state


func _update_hp() -> void:
	Refs.hud.hp_bar.hp = hp


func _on_player_note_hit(_direction: Common.ARROW_DIR, _accuracy: float) -> void:
	hp += hp_gain_player_hit


func _on_player_note_miss(_direction: Common.ARROW_DIR) -> void:
	hp -= hp_loss_player_miss


func _on_player_note_sustain(_direction: Common.ARROW_DIR) -> void:
	hp += (hp_gain_player_sustain * 60.0) * get_process_delta_time()
	
	
func _on_opponent_note_hit(_direction: Common.ARROW_DIR, _accuracy: float) -> void:
	hp += hp_gain_opponent_hit
	if hp >= hp_loss_opponent_cap:
		hp -= hp_loss_opponent_hit


func _on_opponent_note_sustain(_direction: Common.ARROW_DIR) -> void:
	hp += hp_gain_opponent_sustain
	if hp >= hp_loss_opponent_cap:
		hp -= (hp_loss_opponent_sustain * 60.0) * get_process_delta_time()



func load_chart_file(location: String) -> Dictionary:
	var file = FileAccess.open(location, FileAccess.READ)
	var chart_file = file.get_as_text()
	return JSON.parse_string(chart_file)


func load_stage(stage_name: String) -> void:
	if not Registry.stages.has(stage_name):
		push_error("Stage ", stage_name, " not found.\nDefaulting to main_stage.")
		stage_name = "main_stage"
	var stagepacked: PackedScene = load(Registry.stages.get(stage_name))
	Refs.stage = stagepacked.instantiate()
	add_child(Refs.stage)
	move_child(Refs.stage, 0)


func spawn_strumlines() -> void:
	var markers = $StrumLines.get_children()
	var strum_info: Array[Dictionary]
	strum_info.assign(song_metadata.get("strum_lines", []))
	var amount: int = 0
	if not strum_info:
		for i in notes:
			if i.s + 1 > amount:
				amount = i.s + 1
				continue
	else:
		amount = strum_info.size()
	var note_skin_to_apply: NoteSkinResource
	if song_metadata.has("note_skin"):
		note_skin_to_apply = load(Registry.note_skins.get(song_metadata.get("note_skin")))
	else:
		note_skin_to_apply = note_skin
	for i in range(amount):
		var strumline: StrumLine = STRUMLINE_PRELOAD.instantiate()
		var info: Dictionary = strum_info[i] if i < strum_info.size() else {}
		var marker: Marker2D = markers.get(i)
		
		strumline.note_skin = note_skin_to_apply
		strumline.id = info.get("id", i)
		
		if info.has("bot_play"):
			strumline.bot_play = info.get("bot_play")
		else:
			strumline.bot_play = false if i == 0 else true
		
		if info.has("ghost_tapping"):
			strumline.ghost_tapping = info.get("ghost_tapping")
		else:
			strumline.ghost_tapping = true # temporary.
		
		if info.has("pos"):
			var custom_pos_array: Array = info.get("pos")
			strumline.global_position = Vector2(custom_pos_array[0], custom_pos_array[1])
		else:
			strumline.global_position = marker.global_position
		
		if info.has("scale"):
			var custom_scale_array: Array = info.get("scale")
			strumline.scale = Vector2(custom_scale_array[0], custom_scale_array[1])
		else:
			strumline.scale = Vector2.ONE
		
		if info.has("rotation"):
			strumline.rotation_degrees = info.get("rotation")
		else:
			strumline.rotation_degrees = 0
		
		strumline.scroll_speed = scroll_speed
		loading_complete.connect(strumline._on_loading_complete)
		for note: Dictionary in notes:
				if note.s == strumline.id:
					strumline.notes.append(note)
		$StrumLines.add_child(strumline, true)
		Refs.strumlines.append(strumline)
	for marker: Marker2D in markers:
		marker.queue_free()


func spawn_music() -> void:
	var voices: Array = []
	var inst: String
	inst = song_chart.get("inst", "")
	voices = song_chart.get("voices", [])
	if inst:
		$AudioPlayers/AudioStreamPlayerInst.stream = load(inst)
	else:
		push_error("Instumentals not found for song ", song_name, ".")
	if voices.size() <= 0:
		push_warning("No vocals found for song ", song_name, ".")
	for i in voices.size():
		var player: AudioStreamPlayer = AudioStreamPlayer.new()
		player.name = "AudioStreamPlayerID" + str(i)
		player.stream = load(voices[i])
		$AudioPlayers.add_child(player)


func spawn_chars(chars: Dictionary) -> void:
	for i in chars.size():
		var char_name = chars.get(str(i))
		var markers: Array = Refs.stage.get_node("Markers").get_children()
		var marker: CharacterMarker2D
		for child: CharacterMarker2D in markers:
			if child.name.contains(str(i)):
				marker = child
				break
			else:
				continue
		if not Registry.characters.has(char_name):
			push_error('Character: "', char_name, '" not found.')
			continue
		var char_packed: PackedScene = load(Registry.characters.get(char_name))
		var character: Character = char_packed.instantiate()
		var character_size = character.get_node("ReferenceRect").size
		var new_position = Vector2(marker.global_position.x, marker.global_position.y - character_size.y / 2)
		character.global_position = new_position
		character.flip_h = marker.flip_h
		character.flip_v = marker.flip_v
		$Characters.add_child(character, true)
		Refs.characters.append(character)

func spawn_ui() -> void: # Placeholder as charts do not hold ui info right now.
	var new_hpbar_file = Registry.hp_bars.get("normal")
	var new_hpbar = load(new_hpbar_file).instantiate()
	var new_infobar_file = Registry.info_bars.get("base")
	var new_infobar = load(new_infobar_file).instantiate()
	Refs.hud.hp_bar = new_hpbar
	Refs.hud.info_bar = new_infobar
