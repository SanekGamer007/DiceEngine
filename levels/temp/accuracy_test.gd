extends Label

var org_text := "Accuracy: %.2f"
var accr: float = 1.0
var accuracy_added: float = 0.0
var notes_total: int = 0

func _ready() -> void:
	get_node("../../../StrumLines/StrumLineBF").note_pressed.connect(_on_note_pressed)
	get_node("../../../StrumLines/StrumLineBF").note_missed.connect(_on_note_missed)
	text = org_text % (accr * 100.0) + "%"

func _on_note_pressed(id: int, accuracy: float) -> void:
	notes_total += 1
	accuracy_added += accuracy
	accr = accuracy_added / notes_total
	text = org_text % (accr * 100.0) + "%"

func _on_note_missed(id: int) -> void:
	notes_total += 1
	accr = accuracy_added / notes_total
	text = org_text % (accr * 100.0) + "%"
