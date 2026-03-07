extends Label
var upd: int = 0
var fps: float

func _process(delta: float) -> void:
	fps = Engine.get_frames_per_second()
	text = "FPS: %.2f" % fps
