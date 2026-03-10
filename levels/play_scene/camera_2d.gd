extends Camera2D

func _ready() -> void:
	Game.measure.connect(_on_game_measure)

func _process(delta: float) -> void:
	zoom = zoom.lerp(Vector2(0.7, 0.7), delta * Game.bpm / 64)

func _on_game_measure(measure: int) -> void:
	zoom = Vector2(0.73, 0.73)
