extends Character
class_name CharacterDad

func _ready() -> void:
	super._ready()
	$AnimatedSprite2D.flip_h = !flip_h
	$AnimatedSprite2D.flip_v = flip_v
