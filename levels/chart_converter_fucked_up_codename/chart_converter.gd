extends Control

@export_file("*.json") var chart
@export_file("*.json") var metadata
@export var difficulty: String
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
	
	var songname: String = metadata_data.get("name", "ExampleName")
	var songartist: String = metadata_data.get("artist", "Unknown")
	var songcharter: String = metadata_data.get("charter", "Unknown")
	
	var songbpm: int = metadata_data.get("bpm", 120)
	var song_gf: String = "gf"
	
	
	var all_strums: Array = chart_data.get("strumLines")
	var songstage: String = chart_data.get("stage", "main_stage")
	songstage = songstage.to_snake_case()
	var song_characters: Dictionary = chart_data.get("characters", {})
	var song_character_id0: String = all_strums[0].characters[0]
	var song_character_id1: String = all_strums[1].characters[0]
	
	
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
	
	diffs[difficulty] = {
			"bpm": songbpm,
			"scrollspeed": all_scroll_speeds,
			"notes": _convert_notes(all_strums)
	}
	var outchart_dict: Dictionary = {
		"info": {
			"name": songname,
			"artist": songartist,
			"charter": songcharter,
			"version": Common.get_version(),
		},
		"metadata": {
			"stage": songstage,
			"chars": {
				"0": song_character_id0,
				"1": song_character_id1,
			},
			"girlfriend": song_gf,
			"note_skin": new_note_skin,
			"strum_lines": new_strum_lines,
			"generated_by": Common.engine_name + " " + Common.get_version() + " On " + Time.get_datetime_string_from_system(true) + " UTC",
		},
		"chart": diffs,
	}
	var outchart_json = JSON.stringify(outchart_dict, "", false)
	var outfile = FileAccess.open("res://convertedchart.json", FileAccess.WRITE)
	outfile.store_string(outchart_json)
	outfile.close()

func _convert_notes(org_chart: Array) -> Array[Dictionary]:
	var converted_notes: Array[Dictionary]
	for i: int in org_chart.size():
		for note: Dictionary in org_chart[i].get("notes"):
			var id: int = int(note.id)
			var strum = i
			var length: float = note.get("sLen", 0.0)
		
			var new_note: Dictionary = {
				"s": strum,
				"i": id,
				"t": snapped(note.time / 1000.0, 0.0001),
			}
			if length > 0.0:
				new_note["l"] = snapped(length / 1000.0, 0.0001)
			converted_notes.append(new_note)
		
	converted_notes.sort_custom(func(a, b): return a.t < b.t)
	return converted_notes
