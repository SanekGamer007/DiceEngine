extends Area2D
class_name Note

@export var direction: Common.ARROW_DIR = Common.ARROW_DIR.LEFT
@export var note_type: int = 0 ## placeholder
@export var time: float = 0.0
@export var length: float = 0.0
@export var was_pressed: bool = false
@export var scroll_speed: float = 1.0
@export var move_direction: Vector2 = Vector2.UP
@export var clean_pos: float
@export var sprite: Texture2D :
	set(spr):
		sprite = spr
		if is_inside_tree():
			$Sprite2D.texture = spr
@export var sprite_sustains_mid: Texture2D :
	set(spr):
		sprite = spr
		if is_inside_tree():
			$SustainsMid.texture = spr
@export var sprite_sustains_end: Texture2D :
	set(spr):
		sprite = spr
		if is_inside_tree():
			$SustainsMid/Sprite2D.texture = spr
@onready var org_size_scs2d: Vector2 = $SustainArea2D/SustainCollisionShape2D.shape.size

var sustain_size = 0.0

func _ready() -> void:
	$Sprite2D.texture = sprite
	if length != 0.0:
		$SustainArea2D/SustainCollisionShape2D.disabled = false
		$SustainsMid.visible = true
		sustain_size = length * (scroll_speed * Common.magic_scroll_speed_value)
		$SustainsMid.region_rect.size.y = sustain_size - 64
		$SustainsMid/Sprite2D.position.y = sustain_size - 64
		$SustainArea2D/SustainCollisionShape2D.shape.size.y = org_size_scs2d.y + sustain_size
		$SustainArea2D/SustainCollisionShape2D.position.y = (sustain_size) / 2
	else:
		$SustainArea2D/SustainCollisionShape2D.disabled = true
		$SustainsMid.visible = false

func _process(delta: float) -> void:
	var time_diff = time - Game.mus_time
	var distance = time_diff * scroll_speed * Common.magic_scroll_speed_value
	position = distance * (move_direction * -1)
	var head_pos = global_position
	var tail_pos = head_pos - (move_direction * sustain_size)
	var viewport_size = get_viewport_rect().size
	
	var head_out = head_pos.y < -viewport_size.y or head_pos.y > viewport_size.y
	var tail_out = tail_pos.y < -viewport_size.y or tail_pos.y > viewport_size.y
	if head_out and tail_out:
		queue_free()
	#position += move_direction * (scroll_speed * Common.magic_scroll_speed_value) * delta
	

func hold_hit() -> void:
	$Sprite2D.visible = false

func update_clip() -> void:
	var time_passed = Game.mus_time - time
	var cut_pixels = time_passed * (scroll_speed * Common.magic_scroll_speed_value)
	var sustain_size = length * (scroll_speed * Common.magic_scroll_speed_value)
	
	#$SustainsMid.region_rect.position.y = cut_pixels
	$SustainsMid.region_rect.size.y = sustain_size - cut_pixels
	$SustainsMid.position.y = cut_pixels
	$SustainsMid/Sprite2D.position.y = sustain_size - cut_pixels

func end_hit() -> void:
	queue_free()
