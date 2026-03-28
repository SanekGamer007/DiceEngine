extends CanvasLayer
class_name Hud
signal init_done
@onready var ui_location: Control = $Control
var play_scene: PlayScene
var info_bar: Node :
	set(bar):
		if info_bar:
			info_bar.queue_free()
		info_bar = bar
		ui_location.add_child(bar)
var hp_bar: Node :
	set(bar):
		if hp_bar:
			hp_bar.queue_free()
		hp_bar = bar
		ui_location.add_child(bar)
func _init_done() -> void:
	init_done.emit()

func _ready() -> void:
	Game.measure.connect(_on_game_measure)
	$Control.pivot_offset = get_viewport().get_visible_rect().size / 2

func _process(delta: float) -> void:
	$Control.scale = $Control.scale.lerp(Vector2.ONE, delta * Game.bpm / 64)

func _on_game_measure(_measure: int) -> void:
	$Control.scale = Vector2(1.03, 1.03)
