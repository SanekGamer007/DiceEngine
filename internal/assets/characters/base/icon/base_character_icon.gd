extends Control
class_name CharacterIcon

@export var icon: Array[Texture2D] ## First one is losing, second one is normal, third one is dominating
@export var icon_progress: Array[float] = [20.0, 80.0] ## First one is losing, Second one is dominating
@export_color_no_alpha var icon_color: Color
@export var flip_h: bool = false :
	set(b):
		flip_h = b
		if is_inside_tree():
			$TextureRect.flip_h = b
			$TextureRect.position.y = icon_position.y * (-1 if flip_v else 1)
@export var flip_v: bool = false :
	set(b):
		flip_v = b
		if is_inside_tree():
			$TextureRect.flip_v = b
			$TextureRect.position.x = icon_position.x * (-1 if flip_h else 1)
@onready var icon_size: Vector2 = $TextureRect.size * $TextureRect.scale
@onready var icon_position: Vector2 = $TextureRect.position

func _ready() -> void:
	$TextureRect.flip_h = flip_h
	$TextureRect.position.y = icon_position.y * (-1 if flip_v else 1)
	$TextureRect.flip_v = flip_v
	$TextureRect.position.x = icon_position.x * (-1 if flip_h else 1)

func set_icon(idx: int) -> void:
	if idx > icon.size() - 1:
		return
	$TextureRect.texture = icon[idx]

func update_icon(hp_percent: float):
	if hp_percent <= icon_progress[0]:
		set_icon(2)
	elif hp_percent >= icon_progress[1]:
		set_icon(0)
	else:
		set_icon(1)
