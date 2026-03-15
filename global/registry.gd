extends Node

# DO NOT ADD STUFF MANUALLY, they are populated on boot.
# These are placeholders.

# Name: Path
var stages: Dictionary[String, String] = {
	"main_stage": "res://internal/assets/stages/main_stage/",
}

var characters: Dictionary[String, String] = {
	"bf": "res://internal/assets/characters/bf/bf.tscn",
	"dad": "res://internal/assets/characters/dad/dad.tscn",
}

var note_skins: Dictionary[String, String] = {
	"normal": "res://internal/assets/ui/noteskins/normal/res/normal.tres",
}

# SongName, {Diff, {Path, Array[Inst, Voices]}}
var songs: Dictionary[String, Dictionary] = {
	"thorns": {"erect": 
			{
				"chart": "res://assets/songs/thorns/thorns_erect.json",
				"inst": "res://assets/songs/thorns/song/Inst.ogg",
				"voices": ["res://assets/songs/thorns/song/Voices-id0.ogg", "res://assets/songs/thorns/song/Voices-id1.ogg"],
			}
		}
}

var hp_bars: Dictionary[String, String] = {
	"normal": "res://internal/assets/ui/hp_bar/normal/hp_bar.tscn",
}

var info_bars: Dictionary[String, String] = {
	"normal": "res://internal/assets/ui/info_bar/normal/info_bar.tscn",
}

var _chart_diff_prefix_priority: Array[String] = [
	"",
	"erect",
	"night",
	"nightmare",
]

# last entries override the first ones
var song_paths: Array[String] = ["res://assets/songs/"]
var chars_paths: Array[String] = ["res://internal/assets/characters/", "res://assets/characters/"]
var stage_paths: Array[String] = ["res://internal/assets/stages/", "res://assets/stages/"]
var note_skin_paths: Array[String] = ["res://internal/assets/ui/noteskins/", "res://assets/ui/noteskins/"]
var info_bars_path: Array[String] = ["res://internal/assets/ui/info_bar/", "res://assets/ui/info_bar/"]
var hp_bar_paths: Array[String] = ["res://internal/assets/ui/hp_bar/", "res://assets/ui/hp_bar/"]

func _ready() -> void:
	re_init_database()

func re_init_database() -> void:
	characters.clear()
	stages.clear()
	songs.clear()
	note_skins.clear()
	characters.assign(find_chars())
	stages.assign(find_stages())
	songs.assign(find_songs())
	note_skins.assign(find_note_skins())
	hp_bars.assign(find_hp_bars())
	info_bars.assign(find_info_bars())

func find_chars() -> Dictionary[String, String]:
	var found_characters: Dictionary[String, String] = {}
	for path in chars_paths:
		if not DirAccess.dir_exists_absolute(path):
			continue
		var folders = DirAccess.get_directories_at(path)
		for char_name in folders:
			var full_path = path + char_name + "/" + char_name
			if ResourceLoader.exists(full_path + ".tscn"):
				found_characters[char_name] = full_path + ".tscn"
			else:
				var all_files = DirAccess.get_files_at(path + char_name)
				for file in all_files:
					file = file.replace(".remap", "")
					if file.ends_with(".tscn"):
						if char_name == "base":
							break
						found_characters[char_name] = (path + char_name + "/" + file)
						break
	return found_characters

func find_stages() -> Dictionary[String, String]:
	var found_stages: Dictionary[String, String] = {}
	for path in stage_paths:
		if not DirAccess.dir_exists_absolute(path):
			continue
		var folders = DirAccess.get_directories_at(path)
		for stage_name in folders:
			var full_path = path + stage_name + "/" + stage_name
			if ResourceLoader.exists(full_path + ".tscn"):
				found_stages[stage_name] = full_path + ".tscn"
			else:
				var all_files = DirAccess.get_files_at(path + stage_name)
				for file in all_files:
					file = file.replace(".remap", "")
					if file.ends_with(".tscn"):
						found_stages[stage_name] = (path + stage_name + "/" + file)
						break
	return found_stages

func find_songs() -> Dictionary[String, Dictionary]:
	var found_songs: Dictionary[String, Dictionary] = {}
	for path in song_paths:
		if not DirAccess.dir_exists_absolute(path):
			continue
		var folders = DirAccess.get_directories_at(path)
		for song_name in folders:
			var pre_path = path + song_name + "/" + song_name
			for prefix in _chart_diff_prefix_priority:
				var full_prefix: String = "_" + prefix if prefix else ""
				var full_path: String = pre_path + full_prefix + ".json"
				if ResourceLoader.exists(full_path):
					found_songs.merge(_format_song(full_path, song_name), true)
	return found_songs

func find_note_skins() -> Dictionary[String, String]:
	var found_note_skins: Dictionary[String, String] = {}
	for path in note_skin_paths:
		if not DirAccess.dir_exists_absolute(path):
			continue
		var folders = DirAccess.get_directories_at(path)
		for skin_folder in folders:
			var full_path = path + skin_folder + "/res/"
			if DirAccess.dir_exists_absolute(full_path):
				var files = DirAccess.get_files_at(full_path)
				for file in files:
					file = file.replace(".remap", "")
					if file.ends_with(".tres"):
						found_note_skins[skin_folder] = full_path + file
						break
	return found_note_skins

func find_hp_bars() -> Dictionary[String, String]:
	var found_hp_bars: Dictionary[String, String] = {}
	for path in hp_bar_paths:
		if not DirAccess.dir_exists_absolute(path):
			continue
		var folders = DirAccess.get_directories_at(path)
		for hp_bar_folder in folders:
			var full_path = path + hp_bar_folder
			if ResourceLoader.exists(full_path + "/" + hp_bar_folder + ".tscn"):
				found_hp_bars[hp_bar_folder] = full_path + "/" + hp_bar_folder + ".tscn"
			else:
				if DirAccess.dir_exists_absolute(full_path):
					var files = DirAccess.get_files_at(full_path)
					for file in files:
						file = file.replace(".remap", "")
						if file.ends_with(".tscn"):
							found_hp_bars[hp_bar_folder] = full_path + "/" + file
							break
	return found_hp_bars

func find_info_bars() -> Dictionary[String, String]:
	var found_info_bars: Dictionary[String, String] = {}
	for path in info_bars_path:
		if not DirAccess.dir_exists_absolute(path):
			continue
		var folders = DirAccess.get_directories_at(path)
		for info_bar_folder in folders:
			var full_path = path + info_bar_folder
			if ResourceLoader.exists(full_path + "/" + info_bar_folder + ".tscn"):
				found_info_bars[info_bar_folder] = full_path + "/" + info_bar_folder + ".tscn"
			else:
				if DirAccess.dir_exists_absolute(full_path):
					var files = DirAccess.get_files_at(full_path)
					for file in files:
						file = file.replace(".remap", "")
						if file.ends_with(".tscn"):
							found_info_bars[info_bar_folder] = full_path + "/" + file
							break
	return found_info_bars

func _format_song(json_path: String, song_name: String) -> Dictionary[String, Dictionary]:
	var formatted_song: Dictionary[String, Dictionary] = {}
	var file = FileAccess.open(json_path, FileAccess.READ)
	var chart_file = file.get_as_text()
	var chart: Dictionary = JSON.parse_string(chart_file)
	var chart_charts: Dictionary = chart.get("chart", {})
	var chart_diffs: Array[String]
	chart_diffs.assign(chart_charts.keys())
	var diffs: Dictionary
	var music: Dictionary = _get_music(song_name)
	for diff in chart_diffs:
		diffs[diff] = {"chart": json_path}
		diffs[diff].merge(music)
	formatted_song[song_name] = diffs
	return formatted_song

func _get_music(song_name: String) -> Dictionary:
	var found_music: Dictionary = {}
	var inst: String
	var voices: Array
	var music_path: String
	for path in song_paths:
		if DirAccess.dir_exists_absolute(path + song_name + "/song"):
			music_path = path + song_name + "/song"
	if music_path == "":
		return {"inst": "", "voices": []}
	
	for file in DirAccess.get_files_at(music_path):
		file = file.replace(".import", "")
		if file.to_lower().contains("inst"):
			inst = music_path + "/" + file
		else:
			if file.to_lower().begins_with("voices"):
				if not voices.has(music_path + "/" + file):
					voices.append(music_path + "/" + file)
	
	voices.sort()
	found_music = {"inst": inst, "voices": voices}
	return found_music
