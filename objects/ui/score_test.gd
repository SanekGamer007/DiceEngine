extends Label

var org_text := "Score: %d"
var score: int = 0

func _on_ui_init_done() -> void:
	get_node("../../../StrumLines/StrumLine").note_pressed.connect(_on_note_pressed)
	text = org_text % score

func _on_note_pressed(id: int, accuracy: float) -> void:
	if accuracy >= 0.9:
		score += 350
	elif accuracy >= 0.75:
		score += 200
	elif accuracy > 0.50:
		score += 100
	elif accuracy < 0.50:
		score += 50
	text = org_text % score
