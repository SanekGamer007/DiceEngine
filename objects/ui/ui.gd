extends CanvasLayer
signal init_done

func _init_done() -> void:
	init_done.emit()
