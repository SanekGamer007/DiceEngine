extends Transition
var tween: Tween
var transition_showing: bool = false

func show_transition(duration: float = 1.0) -> void:
	if tween:
		tween.kill()
	if transition_showing:
		return
	tween = create_tween()
	tween.tween_property($TextureRect, "position", Vector2(0, -360), duration)
	tween.tween_callback(done.emit)
	transition_showing = true


func hide_transition(duration: float = 1.0) -> void:
	if tween:
		tween.kill()
	if not transition_showing:
		$TextureRect.offset.y = -1440
		return
	tween = create_tween()
	tween.tween_property($TextureRect, "position", Vector2(0, 720), duration)
	tween.tween_property($TextureRect, "position", Vector2(0, -1440), 0)
	tween.tween_callback(done.emit)
	tween.tween_callback(queue_free)
	transition_showing = false
