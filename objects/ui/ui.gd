extends CanvasLayer
signal init_done
@onready var hpbar: HPBar = $VBoxContainer/HBoxContainer2/HPBar
var play_scene: PlayScene :
	set(scene):
		play_scene = scene
		for label: Label in $VBoxContainer/HBoxContainer.get_children():
			if label.has_method("_on_loading_complete"):
				play_scene.loading_complete.connect(label._on_loading_complete)

func _init_done() -> void:
	init_done.emit()
