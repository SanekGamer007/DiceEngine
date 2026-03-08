extends Control

@export_file("*.json") var chart
@export_file("*.json") var metadata
var notes: Array[Dictionary]

func _ready() -> void:
	_start()

func _start() -> void:
	var file = FileAccess.open(chart, FileAccess.READ)
	var chartfile = file.get_as_text()
	var chart_data = JSON.parse_string(chartfile)
	
	var metafile = FileAccess.open(metadata, FileAccess.READ)
	var metadatafile = metafile.get_as_text()
	var metadata_data: Dictionary = JSON.parse_string(metadatafile)
	var meta_playdata: Dictionary = metadata_data.get("playData", {})
	var meta_whyInTheFuckIsItAnArray: Array = metadata_data.get("timeChanges", {})
	var meta_timechanges: Dictionary = meta_whyInTheFuckIsItAnArray[0]
	
	var songname: String = metadata_data.get("songName", "ExampleName")
	var songartist: String = metadata_data.get("artist", "Unknown")
	var songcharter: String = metadata_data.get("charter", "Unknown")
	
	var songstage: String = meta_playdata.get("stage", "main_stage")
	songstage = songstage.to_snake_case()
	var songbpm: int = meta_timechanges.get("bpm", 120)
	var song_characters: Dictionary = meta_playdata.get("characters", {})
	var song_character_id0: String = song_characters.get("player", "bf")
	var song_character_id1: String = song_characters.get("opponent", "dad")
	var song_gf: String = meta_playdata.get("girlfriend", "gf") 
	
	
	var all_notes: Dictionary = chart_data.get("notes")
	var all_scroll_speeds = chart_data.get("scrollSpeed")
	var diffs: Dictionary
	
	var new_note_skin: String = "normal"
	var new_strum_lines: Array[Dictionary] = [
		{
			"id": 0,
			"bot_play": false,
			# "ghost_tapping": false, # If these are not set they are set automatically
			# "pos": [0, 0],
			# "scale": [1.0, 1.0],
			# "rotation": 0, # in degrees
		},
		{
			"id": 1,
			"bot_play": true,
			# "ghost_tapping": false,
			# "pos": [0, 0],
			# "scale": [1.0, 1.0],
			# "rotation": 0,
		}
	]
	for i: String in all_notes:
		var diff_chart = all_notes.get(i, [])
		var diff_scroll = all_scroll_speeds.get(i, 0.0)
		diffs[i.to_lower()] = {
				"bpm": songbpm,
				"scrollspeed": diff_scroll,
				"notes": _convert_notes(diff_chart)
		}
	var outchart_dict: Dictionary = {
		"info": {
			"name": songname,
			"artist": songartist,
			"charter": songcharter,
			"version": Common.engine_version,
		},
		"metadata": {
			"stage": songstage,
			"chars": {
				"0": song_character_id0,
				"1": song_character_id1,
			},
			"girlfriend": song_gf,
			"note_skin": new_note_skin,
			"strum_lines": new_strum_lines
		},
		"chart": diffs,
	}
	var outchart_json = JSON.stringify(outchart_dict, "", false)
	var outfile = FileAccess.open("res://convertedchart.json", FileAccess.WRITE)
	outfile.store_string(outchart_json)
	outfile.close()

func _convert_notes(org_chart: Array) -> Array[Dictionary]:
	var converted_notes: Array[Dictionary]
	for note: Dictionary in org_chart:
		var id: int = int(note.d) % 4
		var strum: int = floori(note.d / 4)
		var length: float = note.get("l", 0.0)
		
		var new_note: Dictionary = {
			"s": strum,
			"i": id,
			"t": snapped(note.t / 1000.0, 0.0001),
		}
		if length > 0.0:
			new_note["l"] = snapped(length / 1000.0, 0.0001)
		converted_notes.append(new_note)
		
	converted_notes.sort_custom(func(a, b): return a.t < b.t)
	return converted_notes
