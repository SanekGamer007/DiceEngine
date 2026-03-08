extends Label

var org_text := "Accuracy: %.2f"
var accr: float = 1.0
var accuracy_added: float = 0.0
var notes_total: int = 0

func _on_loading_complete() -> void:
	for strumline: StrumLine in owner.play_scene.strumlines:
		if not strumline.bot_play:
			strumline.note_pressed.connect(_on_note_pressed)
			strumline.note_ghosted.connect(_on_note_missed)
			strumline.note_missed.connect(_on_note_missed)
	text = org_text % 100.0 + "%"

func _on_note_pressed(direction: Common.ARROW_DIR, accuracy: float) -> void:
	notes_total += 1
	accuracy_added += accuracy
	accr = accuracy_added / notes_total
	text = org_text % (accr * 100.0) + "%"

func _on_note_missed(direction: Common.ARROW_DIR) -> void:
	notes_total += 1
	accr = accuracy_added / notes_total
	text = org_text % (accr * 100.0) + "%"
