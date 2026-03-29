extends Label

func _ready() -> void:
	text = text.format({"enginename": Common.engine_name, "version": Common.get_version()})
