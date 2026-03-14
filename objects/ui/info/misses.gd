extends Label

var org_text := "Misses: %d"
var misses: int = 0

func _on_loading_complete() -> void:
	for strumline: StrumLine in Refs.strumlines:
		if not strumline.bot_play:
			#strumline.note_ghosted.connect(_on_note_missed)
			strumline.note_missed.connect(_on_note_missed)
	text = org_text % misses


func _on_note_missed(_direction: Common.ARROW_DIR) -> void:
	misses += 1
	text = org_text % misses
