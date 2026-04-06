extends RichTextLabel
var org_text = "[b]{engine_name} v{engine_ver}[/b]"

func _ready() -> void:
	org_text = "[b]{engine_name} v{engine_ver}[/b]"
	text = org_text.format({
		"engine_name": Common.engine_name, 
		"engine_ver": Common.get_version(),
	})
