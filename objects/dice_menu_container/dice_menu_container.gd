@tool
extends Container
class_name DiceMenuContainer
## A brief description of the class's role and functionality.
##
## Note for future self: https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_documentation_comments.html

@export var scroll_progress: float = 0.0:
	set(f):
		scroll_progress = f
		queue_sort()
@export var layout: MenuLayout:
	set(l):
		layout = l
		layout.queue_sort.connect(queue_sort)
		layout.queue_resize.connect(update_minimum_size)


func _notification(what):
	if what == NOTIFICATION_SORT_CHILDREN:
		sort_children()


func sort_children() -> void:
	var children: Array[Control]
	for child in get_children():
		if child is Control and child.visible:
			children.append(child)
	if children.is_empty():
		return

	var rects: Array[Rect2]
	if layout:
		rects = layout.calculate_rects(children, scroll_progress)
	else:
		for i in children.size():
			rects.append(Rect2(Vector2.ZERO, children[i].get_minimum_size()))

	for i in children.size():
		fit_child_in_rect(children[i], rects[i])


func _get_minimum_size() -> Vector2:
	var children: Array[Control]
	for child in get_children():
		if child is Control and child.visible:
			children.append(child)

	if children.is_empty() or not layout:
		return Vector2.ZERO
	return layout.calculate_min_size(children)
