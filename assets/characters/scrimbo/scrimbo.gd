extends Character

func _set_flip_h():
	$Sprites.scale.x = abs($Sprites.scale.x) * (1 if flip_h else -1)
