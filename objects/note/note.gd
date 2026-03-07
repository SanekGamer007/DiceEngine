extends Area2D
class_name Note

@export var id: int = 0
@export var note_type: int = 0 ## placeholder
@export var scroll_speed: float = 1.0
@export var direction: Vector2 = Vector2.UP
@export var clean_pos: float
@export var sprite: Texture2D :
	set(spr):
		sprite = spr
		if is_inside_tree():
			$Sprite2D.texture = spr

func _ready() -> void:
	$Sprite2D.texture = sprite

func _process(delta: float) -> void:
	position += direction * (scroll_speed * Common.magic_scroll_speed_value) * delta

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
