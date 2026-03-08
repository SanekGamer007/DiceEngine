extends Label

var org_text := "Score: %d"
var score: int = 0

func _on_loading_complete() -> void:
	for strumline: StrumLine in owner.play_scene.strumlines:
		if not strumline.bot_play:
			strumline.note_pressed.connect(_on_note_pressed)
	text = org_text % score

func _on_note_pressed(direction: Common.ARROW_DIR, accuracy: float) -> void:
	score += Common.judge_ranks[Common.accr_to_rank(accuracy)][0]
	text = org_text % score
