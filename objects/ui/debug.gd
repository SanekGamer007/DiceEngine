extends RichTextLabel
var org_text = "[b]%s v%s[/b]\n  FPS:  %d\n  Memory:  %.2fMB\n  Video Memory:  %.2fMB"

func _ready() -> void:
	_on_update_timeout()

func _on_update_timeout() -> void:
	var fps = Performance.get_monitor(Performance.TIME_FPS)
	var memory_bytes = Performance.get_monitor(Performance.MEMORY_STATIC)
	var memory_mib = memory_bytes / 1024.0 / 1024.0
	var vram_bytes = Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED)
	var vram_mib = vram_bytes / 1024.0 / 1024.0
	text = org_text % [Common.engine_name, Common.get_version(), fps, memory_mib, vram_mib]
