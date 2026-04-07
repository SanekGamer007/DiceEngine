@tool
extends MenuLayout

@export var separation: float = 0.0:
	set(f):
		separation = f
		queue_sort.emit()
		queue_resize.emit()
@export var movement_x: float = 0.0:
	set(f):
		movement_x = f
		queue_sort.emit()
		queue_resize.emit()


func calculate_rects(children: Array[Control], scroll_progress: float) -> Array[Rect2]:
	var base_positions: Array[Vector2] = []
	var base_position: Vector2 = Vector2.ZERO

	for child in children:
		base_positions.append(base_position)
		var min_size: Vector2 = child.get_minimum_size()
		base_position += Vector2(movement_x, min_size.y + separation)

	var current_idx: int = clampi(floori(scroll_progress), 0, children.size() - 1)
	var fraction: float = scroll_progress - current_idx
	var current_min_size: Vector2 = children[current_idx].get_minimum_size()
	var step: Vector2 = Vector2(movement_x, current_min_size.y + separation)
	var offset: Vector2 = base_positions[current_idx] + (step * fraction)

	var rects: Array[Rect2]

	for i in children.size():
		var child = children[i]
		var min_size: Vector2 = child.get_minimum_size()
		var new_rect := Rect2(base_positions[i] - offset, min_size)
		rects.append(new_rect)
	return rects


func calculate_min_size(children: Array[Control]) -> Vector2:
	var max_size_button: Vector2
	for i in children.size():
		var child: Node = children[i]
		if child is Control and child.visible:
			max_size_button = child.get_minimum_size().max(max_size_button)
	return max_size_button
