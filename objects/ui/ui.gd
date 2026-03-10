extends CanvasLayer
signal init_done
@onready var hpbar: HPBar = $Control/VBoxContainer/HBoxContainer2/HPBar
var play_scene: PlayScene :
	set(scene):
		play_scene = scene
		for label: Label in $Control/VBoxContainer/HBoxContainer.get_children():
			if label.has_method("_on_loading_complete"):
				play_scene.loading_complete.connect(label._on_loading_complete)

func _init_done() -> void:
	init_done.emit()

func _ready() -> void:
	Game.measure.connect(_on_game_measure)
	$Control.pivot_offset = get_viewport().get_visible_rect().size / 2

func _process(delta: float) -> void:
	$Control.scale = $Control.scale.lerp(Vector2.ONE, delta * Game.bpm / 64)

func _on_game_measure(measure: int) -> void:
	$Control.scale = Vector2(1.03, 1.03)
