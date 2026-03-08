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
@export var note_skin: NoteSkinResource :
	set(skin):
		note_skin = skin
		_set_note_skin(skin)
@onready var org_size_scs2d: Vector2 = $SustainArea2D/SustainCollisionShape2D.shape.size

var sustain_size = 0.0

func _ready() -> void:
	if length != 0.0:
		$SustainArea2D/SustainCollisionShape2D.disabled = false
		$SustainsMid.visible = true
		sustain_size = length * (scroll_speed * Common.magic_scroll_speed_value)
		$SustainsMid.region_rect.size.y = (sustain_size - 64) / $SustainsMid.scale.y
		$SustainsMid/Sprite2D.position.y = (sustain_size - 64) / $SustainsMid.scale.y
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
	
	var top_y = min(head_pos.y, tail_pos.y)
	var bottom_y = max(head_pos.y, tail_pos.y)
	
	if bottom_y < -viewport_size.y or top_y > viewport_size.y:
		queue_free()
	#position += move_direction * (scroll_speed * Common.magic_scroll_speed_value) * delta
	

func hold_hit() -> void:
	$Sprite2D.visible = false

func update_clip() -> void:
	var time_passed = Game.mus_time - time
	var cut_pixels = time_passed * (scroll_speed * Common.magic_scroll_speed_value)
	var sustain_size = length * (scroll_speed * Common.magic_scroll_speed_value)
	
	#$SustainsMid.region_rect.position.y = cut_pixels
	$SustainsMid.region_rect.size.y = (sustain_size - cut_pixels) / $SustainsMid.scale.y
	$SustainsMid.position.y = cut_pixels
	$SustainsMid/Sprite2D.position.y = (sustain_size - cut_pixels) / $SustainsMid.scale.y

func end_hit() -> void:
	queue_free()

func _set_note_skin(skin: NoteSkinResource) -> void:
	$Sprite2D.texture = skin.note_skins[direction]
	$SustainsMid.texture = skin.sust_body[direction]
	$SustainsMid.region_rect = Rect2(0,0,skin.sust_body[0].get_width(), skin.sust_body[0].get_height())
	$SustainsMid.position.x = ((skin.sust_body[0].get_width() / 2) * skin.note_scale.x) * -1
	$SustainsMid/Sprite2D.texture = skin.sust_end[direction]
	$SustainsMid/Sprite2D.region_rect = Rect2(0,0,skin.sust_end[0].get_width(), skin.sust_end[0].get_height())
	$Sprite2D.scale = skin.note_scale
	if skin.g_is_pixel:
		$Sprite2D.texture_filter = TextureFilter.TEXTURE_FILTER_NEAREST
		$SustainsMid.texture_filter = TextureFilter.TEXTURE_FILTER_NEAREST
		$SustainsMid/Sprite2D.texture_filter = TextureFilter.TEXTURE_FILTER_NEAREST
	else:
		$Sprite2D.texture_filter = TextureFilter.TEXTURE_FILTER_PARENT_NODE
		$SustainsMid.texture_filter = TextureFilter.TEXTURE_FILTER_PARENT_NODE
		$SustainsMid/Sprite2D.texture_filter = TextureFilter.TEXTURE_FILTER_PARENT_NODE
	$SustainsMid.scale = skin.note_scale
	#$SustainsMid/Sprite2D.scale = skin.g_scale
