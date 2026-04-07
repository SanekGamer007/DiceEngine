extends RichTextLabel
var org_text = text

func _ready() -> void:
	await get_tree().process_frame
	text = org_text.format({
		"engine": Common.engine_name, 
		"version": Common.get_version(),
		"commit": FileAccess.get_file_as_string("res://commit.txt"),
	})
