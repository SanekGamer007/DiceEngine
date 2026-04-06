extends Node

# DO NOT ADD STUFF MANUALLY, they are populated on boot.
# These are placeholders.

var stages: Dictionary[String, String] = { }
var characters: Dictionary[String, String] = {
	"bf": "res://internal/assets/characters/bf/bf.tscn",
	"dad": "res://internal/assets/characters/dad/dad.tscn",
}
var noteskins: Dictionary[String, String] = { }
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

var _chart_diff_prefix_priority: Array[String] = [
	"",
	"erect",
	"night",
	"nightmare",
]

const song_base_path: String = "songs/"
const chars_base_path: String = "characters/"
const stage_base_path: String = "stages/"
const noteskins_base_path: String = "ui/noteskins/"
const info_bars_base_path: String = "ui/info_bars/"
const hp_bars_base_path: String = "ui/hp_bars/"
const menus_base_path: String = "menus/"
const music_base_path: String = "music/"
const sounds_base_path: String = "sounds/"
const transitions_base_path: String = "ui/transitions/"

# last entries override the first ones
var songs_paths: Array[String]
var characters_paths: Array[String]
var stages_paths: Array[String]
var noteskins_paths: Array[String]
var info_bars_paths: Array[String]
var hp_bars_paths: Array[String]
var menus_paths: Array[String]
var music_paths: Array[String]
var sounds_paths: Array[String]
var transitions_paths: Array[String]

enum SEARCH_TYPE {
	FOLDER,
	FILE,
}

signal database_rebuilt


func rebuild_database() -> void:
	characters.clear()
	stages.clear()
	songs.clear()
	noteskins.clear()
	menus.clear()
	music.clear()
	sounds.clear()
	transitions.clear()

	characters.assign(_find_asset(characters_paths, [".tscn", ".scn"], SEARCH_TYPE.FOLDER))
	stages.assign(_find_asset(stages_paths, [".tscn", ".scn"], SEARCH_TYPE.FOLDER))
	songs.assign(_find_songs())
	noteskins.assign(_find_asset(noteskins_paths, [".tres", ".res"], SEARCH_TYPE.FOLDER))
	hp_bars.assign(_find_asset(hp_bars_paths, [".tscn", ".scn"], SEARCH_TYPE.FOLDER))
	info_bars.assign(_find_asset(info_bars_paths, [".tscn", ".scn"], SEARCH_TYPE.FOLDER))
	menus.assign(_find_asset(menus_paths, [".tscn", ".scn"], SEARCH_TYPE.FOLDER))
	music.assign(_find_asset(music_paths, [".ogg", ".mp3", ".wav"], SEARCH_TYPE.FILE))
	sounds.assign(_find_asset(sounds_paths, [".ogg", ".mp3", ".wav"], SEARCH_TYPE.FILE))
	transitions.assign(_find_asset(transitions_paths, [".tscn", ".scn"], SEARCH_TYPE.FOLDER))

	database_rebuilt.emit()


func _find_songs() -> Dictionary[String, Dictionary]:
	var found_songs: Dictionary[String, Dictionary] = { }
	for path in songs_paths:
		if not DirAccess.dir_exists_absolute(path):
			continue
		var folders = DirAccess.get_directories_at(path)
		for song_name in folders:
			var pre_path = path.path_join(song_name).path_join(song_name)
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
					var full_path = path.path_join(folder)
					if not DirAccess.dir_exists_absolute(full_path):
						continue
					for extension in extensions:
						if ResourceLoader.exists(full_path.path_join(folder + extension)):
							found_assets[folder] = full_path.path_join(folder + extension)
							break
						else:
							var files = ResourceLoader.list_directory(full_path)
							for file in files:
								if file.ends_with(extension):
									found_assets[folder] = full_path.path_join(file)
		SEARCH_TYPE.FILE:
			for path in paths:
				if not DirAccess.dir_exists_absolute(path):
					continue
				var files = ResourceLoader.list_directory(path)
				for file in files:
					for extension in extensions:
						if file.ends_with(extension):
							found_assets[file.replace(extension, "")] = path + file
							continue
	return found_assets


func _add_paths(paths: Dictionary[String, String]) -> void:
	for key in paths:
		var property_name: String = key + "_paths"
		if property_name in self:
			var property = get(property_name)
			if property is Array and not property.has(paths[key]):
				property.append(paths[key])


func _remove_paths(paths: Dictionary[String, String]) -> void:
	for key in paths:
		var property_name: String = key + "_paths"
		if property_name in self:
			var property = get(property_name)
			if property is Array:
				property.erase(paths[key])


func _format_song(json_path: String, song_name: String) -> Dictionary[String, Dictionary]:
	var formatted_song: Dictionary[String, Dictionary] = { }
	var chart_file = FileAccess.get_file_as_string(json_path)
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
	var voices: Array[String]
	var music_path: String
	for path in songs_paths:
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
