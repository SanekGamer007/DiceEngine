extends Label

var org_text := "Combo: %d"
var combo: int = 0

func _on_ui_init_done() -> void:
	get_node("../../../StrumLines/StrumLine").note_pressed.connect(_on_note_pressed)
	get_node("../../../StrumLines/StrumLine").note_missed.connect(_on_note_missed)
	text = org_text % combo

func _on_note_pressed(id: int, accuracy: float) -> void:
	combo += 1
	text = org_text % combo

func _on_note_missed(id: int) -> void:
	combo = 0
	text = org_text % combo
