extends HPBar

func _process(delta: float) -> void:
	right_bar.size.x = lerp(right_bar.size.x, total_px - middle, delta * 8)
	right_bar.position.x = lerp(right_bar.position.x, middle, delta * 8)
	if flip_bar:
		left_icon.position.x = right_bar.position.x + 5
		right_icon.position.x = right_bar.position.x - 95
	else:
		left_icon.position.x = right_bar.position.x - 95
		right_icon.position.x = right_bar.position.x + 5
	super(delta)

func _update_bar() -> void:
	if not left_bar or not right_bar or not right_icon or not left_icon:
		return
	var percentage = 1.0 - (hp / 100.0)
	middle = total_px * percentage
	left_bar.size.x = $Panel.size.x
	
	var left_hp_percent: float
	var right_hp_percent: float
	if flip_bar:
		left_hp_percent = hp
		right_hp_percent = 100.0 - hp
	else:
		right_hp_percent = 100.0 - hp
		left_hp_percent = hp
	
	left_icon.update_icon(left_hp_percent)
	right_icon.update_icon(right_hp_percent)
