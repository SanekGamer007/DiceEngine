extends RichTextLabel
var org_text = "[b]{engine_name} v{engine_ver}[/b]\n  FPS:  {fps}\n  Memory:  {ram}MB\n  Video Memory:  {vram}MB"

func _ready() -> void:
	_on_update_timeout()
	if not OS.is_debug_build():
		org_text = "[b]{engine_name} v{engine_ver}[/b]\n  FPS:  {fps}\n  Video Memory:  {vram}MB"
		_on_update_timeout()
		
func _on_update_timeout() -> void:
	var fps = Performance.get_monitor(Performance.TIME_FPS)
	var memory_bytes = Performance.get_monitor(Performance.MEMORY_STATIC)
	var memory_mib = "%.2f" % float(memory_bytes / 1024.0 / 1024.0)
	var vram_bytes: float = Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED)
	var vram_mib = "%.2f" % float(vram_bytes / 1024.0 / 1024.0)
	text = org_text.format({
		"engine_name": Common.engine_name, 
		"engine_ver": Common.get_version(),
		"fps": fps,
		"ram": memory_mib,
		"vram": vram_mib
		})
