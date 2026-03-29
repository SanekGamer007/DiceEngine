extends AudioStreamPlayer

func _ready() -> void:
	stream = load(Registry.sounds.get("confirm_menu"))
