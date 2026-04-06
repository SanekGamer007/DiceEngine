extends RichTextLabel
var org_text: String = text

func _ready() -> void:
	_on_update_timeout()

func _on_update_timeout() -> void:
	var fps = Performance.get_monitor(Performance.TIME_FPS)
	var memory_bytes = Performance.get_monitor(Performance.MEMORY_STATIC)
	var memory_mib = "%.2f" % float(memory_bytes / 1024.0 / 1024.0)
	var vram_bytes: float = Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED)
	var vram_mib = "%.2f" % float(vram_bytes / 1024.0 / 1024.0)
	text = org_text.format({
		"fps": fps,
		"ram": memory_mib,
		"vram": vram_mib,
		"mods": ", ".join(ModManager.enabled_mods.keys().map(func(s): return s.capitalize()))
		})
