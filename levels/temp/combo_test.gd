extends Label

var org_text := "Combo: %d"
var combo: int = 0

func _ready() -> void:
	get_node("../../../StrumLines/StrumLineBF").note_pressed.connect(_on_note_pressed)
	get_node("../../../StrumLines/StrumLineBF").note_missed.connect(_on_note_missed)
	text = org_text % combo

func _on_note_pressed(id: int, accuracy: float) -> void:
	combo += 1
	text = org_text % combo

func _on_note_missed(id: int) -> void:
	combo = 0
	text = org_text % combo
