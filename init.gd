extends Node

func _ready() -> void:
	Registry.re_init_database()
	var path = Registry.menus.get("title", "res://internal/assets/menus/freeplay_proto/freeplay.tscn")
	get_tree().change_scene_to_file.call_deferred(path)
