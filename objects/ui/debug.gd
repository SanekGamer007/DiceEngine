extends Label
var org_text = "Dice Engine v%s\nFPS: %d\nMemory: %.2fMB\nVideo Memory: %.2fMB"

func _process(delta: float) -> void:
	var fps = Performance.get_monitor(Performance.TIME_FPS)
	var memory_bytes = Performance.get_monitor(Performance.MEMORY_STATIC)
	var memory_mib = memory_bytes / 1024.0 / 1024.0
	var vram_bytes = Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED)
	var vram_mib = vram_bytes / 1024.0 / 1024.0
	text = org_text % [Common.engine_version, fps, memory_mib, vram_mib]
