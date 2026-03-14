extends CanvasLayer

func _ready() -> void:
	Game.measure.connect(_on_game_measure)

func _process(delta: float) -> void:
	scale = scale.lerp(Vector2.ONE, delta * Game.bpm / 64)

func _on_game_measure(_measure: int) -> void:
	scale = Vector2(1.03, 1.03)
