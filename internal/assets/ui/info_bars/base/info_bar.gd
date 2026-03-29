extends HBoxContainer

func _ready() -> void:
	for label: Label in get_children():
		if label.has_method("_on_loading_complete"):
			Refs.play_scene.loading_complete.connect(label._on_loading_complete)
