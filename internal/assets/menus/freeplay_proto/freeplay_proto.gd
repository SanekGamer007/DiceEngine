extends Control

var selected_song: String = ""
var selected_diff: String = ""

var play_packed: PackedScene = load("res://levels/play_scene/play_scene.tscn")

func _ready() -> void:
	MusicManager.play("freaky_menu", 1.0, true, 3.0, false, 3.0)
	$VBoxContainer/HBoxContainer/Label.text = Common.engine_name + " v" + Common.get_version() + "\nFreeplay\nWIP"
	$VBoxContainer/HBoxContainer2/VBoxContainer/ItemList.clear()
	for song in Registry.songs:
		$VBoxContainer/HBoxContainer2/VBoxContainer/ItemList.add_item(song)
	$VBoxContainer/HBoxContainer2/VBoxContainer2/ItemList.clear()


func _on_item_list_item_selected(index: int) -> void:
	$VBoxContainer/HBoxContainer2/VBoxContainer2/ItemList.clear()
	selected_diff = ""
	selected_song = Registry.songs.keys()[index]
	var available_diffs = Registry.songs.get(selected_song).keys()
	for diff in available_diffs:
		$VBoxContainer/HBoxContainer2/VBoxContainer2/ItemList.add_item(diff)

func _on_item_list_diff_item_selected(index: int) -> void:
	var available_diffs = Registry.songs.get(selected_song).keys()
	selected_diff = available_diffs[index]


func _on_button_pressed() -> void:
	MusicManager.stop(true, 1.0)
	if not selected_song or not selected_diff:
		return
	print(selected_song, selected_diff)
	var play_scene: PlayScene = play_packed.instantiate()
	play_scene.song_name = selected_song
	play_scene.difficulty = selected_diff
	TransitionManager.change_scene_to_node(play_scene, "fade", 1.0)
