extends Button

func _on_pressed() -> void:
	TransitionManager.change_scene_to_file(Registry.menus.get("main"), "fade", 1.0)
