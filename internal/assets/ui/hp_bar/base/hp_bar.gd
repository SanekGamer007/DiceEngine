extends Node2D
class_name HPBar

var hp: float = 50 :
	set(amm):
		hp = amm
		_update_bar()
@onready var total_px: float = $Panel.size.x
@onready var left_bar: ColorRect = $Bar_Opponent
@onready var right_bar: ColorRect = $Bar_Player
@export var left_icon: CharacterIcon :
	set(icon):
		if is_inside_tree() and left_icon:
			left_icon.queue_free()
		left_icon = icon
		if is_inside_tree() and left_icon:
			$Icons.add_child(left_icon)
			left_bar.color = icon.icon_color
			if flip_bar:
				left_icon.position.x = right_bar.position.x + 5
			else:
				left_icon.position.x = right_bar.position.x - 95
@export var right_icon: CharacterIcon :
	set(icon):
		if is_inside_tree() and right_icon:
			right_icon.queue_free()
		right_icon = icon
		if is_inside_tree() and right_icon:
			$Icons.add_child(right_icon)
			right_bar.color = icon.icon_color
			if flip_bar:
				right_icon.position.x = right_bar.position.x - 95
			else:
				right_icon.position.x = right_bar.position.x + 5
@export var flip_bar: bool
var middle: float = 0.0

func _ready() -> void:
	if left_icon and not left_icon.is_inside_tree():
		$Icons.add_child(left_icon)
	if right_icon and not left_icon.is_inside_tree():
		$Icons.add_child(right_icon)
	left_bar.color = left_icon.icon_color
	right_bar.color = right_icon.icon_color
	Game.beat.connect(beat_hit)
	_update_bar.call_deferred()

func _process(delta: float) -> void:
	if not left_icon or not right_icon:
		return
	left_icon.scale = left_icon.scale.lerp(Vector2.ONE, delta * Game.bpm / 12)
	left_icon.pivot_offset.y = left_icon.icon_size.y / 2
	left_icon.pivot_offset.x = left_icon.icon_size.x
	right_icon.scale = right_icon.scale.lerp(Vector2.ONE, delta * Game.bpm / 12)
	right_icon.pivot_offset.y = right_icon.icon_size.y / 2
	right_icon.pivot_offset.x = 0

func _update_bar() -> void:
	if not left_bar or not right_bar or not right_icon or not left_icon:
		return
	var percentage = 1.0 - (hp / 100.0)
	middle = total_px * percentage
	left_bar.size.x = $Panel.size.x
	right_bar.size.x = (total_px - middle)
	right_bar.position.x = middle
	
	var left_hp_percent: float
	var right_hp_percent: float
	if flip_bar:
		left_hp_percent = hp
		right_hp_percent = 100.0 - hp
		left_icon.position.x = right_bar.position.x + 5
		right_icon.position.x = right_bar.position.x - 95
	else:
		right_hp_percent = 100.0 - hp
		left_hp_percent = hp
		left_icon.position.x = right_bar.position.x - 95
		right_icon.position.x = right_bar.position.x + 5
	
	left_icon.update_icon(left_hp_percent)
	right_icon.update_icon(right_hp_percent)

func beat_hit(_count: int):
	left_icon.scale = Vector2(1.2, 1.2)
	right_icon.scale = Vector2(1.2, 1.2)
