extends Node

func _ready() -> void:
	var path = Registry.menus.get("title", "res://internal/assets/menus/freeplay_proto/freeplay.tscn")
	get_tree().change_scene_to_file.call_deferred(path)
	if OS.has_feature("editor"):
		_get_commit_hash()
	
func _get_commit_hash() -> void:
	var out: Array[String]
	var exit_code = OS.execute("git", ["rev-parse", "--short", "HEAD"], out)
	
	if exit_code == 0:
		var commit = out[0].strip_edges()
		var file = FileAccess.open("res://commit.txt", FileAccess.WRITE)
		print(commit)
		
		file.store_string(commit)
		file.close()
	else:
		print_debug("Git repo not found.")
