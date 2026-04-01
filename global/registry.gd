extends Node

# DO NOT ADD STUFF MANUALLY, they are populated on boot.
# These are placeholders.

var stages: Dictionary[String, String] = { }
var characters: Dictionary[String, String] = {
	"bf": "res://internal/assets/characters/bf/bf.tscn",
	"dad": "res://internal/assets/characters/dad/dad.tscn",
}
var note_skins: Dictionary[String, String] = { }
var songs: Dictionary[String, Dictionary] = {
	"thorns": {
		"erect": {
			"chart": "res://assets/songs/thorns/thorns_erect.json",
			"inst": "res://assets/songs/thorns/song/Inst.ogg",
			"voices": ["res://assets/songs/thorns/song/Voices-id0.ogg", "res://assets/songs/thorns/song/Voices-id1.ogg"],
		},
	},
}
var hp_bars: Dictionary[String, String] = { }
var info_bars: Dictionary[String, String] = { }
var menus: Dictionary[String, String] = { }
var music: Dictionary[String, String] = { }
var sounds: Dictionary[String, String] = { }
var transitions: Dictionary[String, String] = { }
var found_mods: Dictionary[String, String]
var enabled_mods: Dictionary[String, String]

var _chart_diff_prefix_priority: Array[String] = [
	"",
	"erect",
	"night",
	"nightmare",
]

const song_base_paths: Array[String] = ["res://assets/songs/"]
const chars_base_paths: Array[String] = ["res://internal/assets/characters/", "res://assets/characters/"]
const stage_base_paths: Array[String] = ["res://internal/assets/stages/", "res://assets/stages/"]
const noteskins_base_paths: Array[String] = ["res://internal/assets/ui/noteskins/", "res://assets/ui/noteskins/"]
const info_bars_base_paths: Array[String] = ["res://internal/assets/ui/info_bars/", "res://assets/ui/info_bars/"]
const hp_bars_base_paths: Array[String] = ["res://internal/assets/ui/hp_bars/", "res://assets/ui/hp_bars/"]
const menus_base_paths: Array[String] = ["res://internal/assets/menus/", "res://assets/menus/"]
const music_base_paths: Array[String] = ["res://internal/assets/music/", "res://assets/music/"]
const sounds_base_paths: Array[String] = ["res://internal/assets/sounds/", "res://assets/sounds/"]
const transitions_base_paths: Array[String] = ["res://internal/assets/ui/transitions/", "res://assets/ui/transitions/"]
const mods_base_paths: Array[String] = ["user://mods/"]

# last entries override the first ones
var song_paths: Array[String]
var chars_paths: Array[String]
var stage_paths: Array[String]
var noteskins_paths: Array[String]
var info_bars_paths: Array[String]
var hp_bars_paths: Array[String]
var menus_paths: Array[String]
var music_paths: Array[String]
var sounds_paths: Array[String]
var transitions_paths: Array[String]
var mods_paths: Array[String]

enum SEARCH_TYPE {
	FOLDER,
	FILE,
}

func _ready() -> void:
	mods_paths.append(OS.get_executable_path().get_base_dir() + "/mods/")
	if OS.has_feature("editor"):
		mods_paths.append("res://mods/")
	reset_paths()
	Registry.re_init_database()


func re_init_database() -> void:
	characters.clear()
	stages.clear()
	songs.clear()
	note_skins.clear()
	menus.clear()
	music.clear()
	sounds.clear()
	transitions.clear()
	found_mods.clear()

	characters.assign(_find_asset(chars_paths, [".tscn", ".scn"], SEARCH_TYPE.FOLDER))
	stages.assign(_find_asset(stage_paths, [".tscn", ".scn"], SEARCH_TYPE.FOLDER))
	songs.assign(find_songs())
	note_skins.assign(_find_asset(noteskins_paths, [".tres", ".res"], SEARCH_TYPE.FOLDER))
	hp_bars.assign(_find_asset(hp_bars_paths, [".tscn", ".scn"], SEARCH_TYPE.FOLDER))
	info_bars.assign(_find_asset(info_bars_paths, [".tscn", ".scn"], SEARCH_TYPE.FOLDER))
	menus.assign(_find_asset(menus_paths, [".tscn", ".scn"], SEARCH_TYPE.FOLDER))
	music.assign(_find_asset(music_paths, [".ogg", ".mp3", ".wav"], SEARCH_TYPE.FILE))
	sounds.assign(_find_asset(sounds_paths, [".ogg", ".mp3", ".wav"], SEARCH_TYPE.FILE))
	transitions.assign(_find_asset(transitions_paths, [".tscn", ".scn"], SEARCH_TYPE.FOLDER))
	found_mods.assign(find_mods())

	TransitionManager.find_transitions()


func reset_paths() -> void:
	song_paths = song_base_paths.duplicate()
	chars_paths = chars_base_paths.duplicate()
	stage_paths = stage_base_paths.duplicate()
	noteskins_paths = noteskins_base_paths.duplicate()
	info_bars_paths = info_bars_base_paths.duplicate()
	hp_bars_paths = hp_bars_base_paths.duplicate()
	menus_paths = menus_base_paths.duplicate()
	music_paths = music_base_paths.duplicate()
	sounds_paths = sounds_base_paths.duplicate()
	transitions_paths = transitions_base_paths.duplicate()
	mods_paths = mods_base_paths.duplicate()


func find_songs() -> Dictionary[String, Dictionary]:
	var found_songs: Dictionary[String, Dictionary] = { }
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


func _find_asset(paths: Array[String], extensions: Array[String], type: SEARCH_TYPE) -> Dictionary[String, String]:
	var found_assets: Dictionary[String, String]
	match type:
		SEARCH_TYPE.FOLDER:
			for path in paths:
				if not DirAccess.dir_exists_absolute(path):
					continue
				var folders = DirAccess.get_directories_at(path)
				for folder in folders:
					var full_path = path + folder
					if not DirAccess.dir_exists_absolute(full_path):
						continue
					for extension in extensions:
						if ResourceLoader.exists(full_path + "/" + folder + extension):
							found_assets[folder] = full_path + "/" + folder + extension
							break
						else:
							var files = DirAccess.get_files_at(full_path)
							for file in files:
								file = file.trim_suffix(".remap").trim_suffix(".import")
								if file.ends_with(extension):
									found_assets[folder] = full_path + "/" + file
		SEARCH_TYPE.FILE:
			for path in paths:
				if not DirAccess.dir_exists_absolute(path):
					continue
				var files = DirAccess.get_files_at(path)
				for file in files: 
					file = file.trim_suffix(".remap").trim_suffix(".import")
					for extension in extensions:
						if file.ends_with(extension):
							found_assets[file.replace(extension, "")] = path + file
							continue
	return found_assets


func find_mods() -> Dictionary[String, String]:
	return { }


func _format_song(json_path: String, song_name: String) -> Dictionary[String, Dictionary]:
	var formatted_song: Dictionary[String, Dictionary] = { }
	var file = FileAccess.open(json_path, FileAccess.READ)
	var chart_file = file.get_as_text()
	var chart: Dictionary = JSON.parse_string(chart_file)
	var chart_charts: Dictionary = chart.get("chart", { })
	var chart_diffs: Array[String]
	chart_diffs.assign(chart_charts.keys())
	var diffs: Dictionary
	var song: Dictionary = _get_music(song_name)
	for diff in chart_diffs:
		diffs[diff] = { "chart": json_path }
		diffs[diff].merge(song)
	formatted_song[song_name] = diffs
	return formatted_song


func _get_music(song_name: String) -> Dictionary:
	var found_music: Dictionary = { }
	var inst: String
	var voices: Array
	var music_path: String
	for path in song_paths:
		if DirAccess.dir_exists_absolute(path + song_name + "/song"):
			music_path = path + song_name + "/song"
	if music_path == "":
		return { "inst": "", "voices": [] }

	for file in DirAccess.get_files_at(music_path):
		file = file.replace(".import", "")
		if file.to_lower().contains("inst"):
			inst = music_path + "/" + file
		else:
			if file.to_lower().begins_with("voices"):
				if not voices.has(music_path + "/" + file):
					voices.append(music_path + "/" + file)

	voices.sort()
	found_music = { "inst": inst, "voices": voices }
	return found_music
