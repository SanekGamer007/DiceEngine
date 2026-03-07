extends Label

var org_text := "Misses: %d"
var misses: int = 0

func _ready() -> void:
	get_node("../../../StrumLines/StrumLineBF").note_missed.connect(_on_note_missed)
	get_node("../../../StrumLines/StrumLineBF").note_ghosted.connect(_on_note_missed)
	text = org_text % misses


func _on_note_missed(id: int) -> void:
	misses += 1
	text = org_text % misses
