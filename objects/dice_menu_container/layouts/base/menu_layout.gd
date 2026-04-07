@tool
extends Node
class_name MenuLayout

signal queue_sort
signal queue_resize


func calculate_rects(children: Array[Control], scroll_progress: float) -> Array[Rect2]:
	return []


func calculate_min_size(children: Array[Control]) -> Vector2:
	return Vector2.ZERO
