extends Node2D
class_name HPBar

var hp: float = 50 :
	set(amm):
		hp = amm
		_update_bar()
@onready var total_px: float = $Panel.size.x
@onready var left_bar: ColorRect = $Bar_Opponent
@onready var right_bar: ColorRect = $Bar_Player
@onready var left_icon: TextureRect = $Icon_Opponent
@onready var right_icon: TextureRect = $Icon_Player

@export var player_icons: Array[Texture2D] :
	set(spr):
		player_icons = spr
		if is_inside_tree():
			$Icon_Player.texture = spr[1]
			$Icon_Player.size.y = spr[1].get_height()
			if spr[1].get_width() >= 64:
				$Icon_Player.expand_mode = TextureRect.ExpandMode.EXPAND_KEEP_SIZE
			else:
				$Icon_Player.expand_mode = TextureRect.ExpandMode.EXPAND_FIT_HEIGHT
@export var player_thresholds: Array[float] = [20.0, 80.0]
@export_color_no_alpha var player_color: Color = Color.GREEN :
	set(col):
		player_color = col
		if is_inside_tree():
			$Bar_Player.color = col
@export var player_filter: TextureFilter = TextureFilter.TEXTURE_FILTER_PARENT_NODE :
	set(filter):
		player_filter = filter
		if is_inside_tree():
			$Icon_Player.texture_filter = filter
@export var opponent_icons: Array[Texture2D] :
	set(spr):
		opponent_icons = spr
		if is_inside_tree():
			$Icon_Opponent.texture = spr[1]
			$Icon_Opponent.size.y = spr[1].get_height()
			print(spr[1].get_width())
			if spr[1].get_width() >= 64:
				$Icon_Opponent.expand_mode = TextureRect.ExpandMode.EXPAND_KEEP_SIZE
			else:
				$Icon_Opponent.expand_mode = TextureRect.ExpandMode.EXPAND_FIT_HEIGHT
@export_color_no_alpha var opponent_color: Color = Color.RED :
	set(col):
		opponent_color = col
		if is_inside_tree():
			$Bar_Opponent.color = col
@export var opponent_thresholds: Array[float] = [20.0, 80.0]
@export var opponent_filter: TextureFilter = TextureFilter.TEXTURE_FILTER_PARENT_NODE :
	set(filter):
		opponent_filter = filter
		if is_inside_tree():
			$Icon_Opponent.texture_filter = filter
func _ready() -> void:
	$Icon_Player.texture = player_icons[1]
	$Icon_Player.texture_filter = player_filter
	$Icon_Opponent.texture = opponent_icons[1]
	$Icon_Opponent.texture_filter = opponent_filter
	$Bar_Player.color = player_color
	$Bar_Opponent.color = opponent_color
	Game.beat.connect(beat_hit)

func _process(delta: float) -> void:
	left_icon.scale = left_icon.scale.lerp(Vector2.ONE, delta * Game.bpm / 12)
	left_icon.pivot_offset.y = left_icon.size.y / 2
	left_icon.pivot_offset.x = left_icon.size.x
	right_icon.scale = right_icon.scale.lerp(Vector2.ONE, delta * Game.bpm / 12)
	right_icon.pivot_offset.y = right_icon.size.y / 2
	right_icon.pivot_offset.x = 0

func _update_bar() -> void:
	if not left_bar and right_bar:
		return
	var percentage = 1.0 - (hp / 100.0)
	var middle = total_px * percentage
	left_bar.size.x = middle + 1.0
	if left_bar.size.x - 1.0 >= $Panel.size.x:
		left_bar.size.x = middle - 1.0
	right_bar.size.x = (total_px - middle) - 1.0
	right_bar.position.x = middle
	
	left_icon.position.x = left_bar.size.x - 95
	right_icon.position.x = right_bar.position.x + 5
	
	var player_hp_percent = hp
	var opponent_hp_percent = 100.0 - hp 
	
	if player_hp_percent <= opponent_thresholds[0]:
		left_icon.texture = opponent_icons[2]
	elif player_hp_percent >= opponent_thresholds[1]:
		left_icon.texture = opponent_icons[0]
	else:
		left_icon.texture = opponent_icons[1]
	
	if opponent_hp_percent <= player_thresholds[0]:
		right_icon.texture = player_icons[2]
	elif opponent_hp_percent >= player_thresholds[1]:
		right_icon.texture = player_icons[0]
	else:
		right_icon.texture = player_icons[1]
	

func beat_hit(_count: int):
	left_icon.scale = Vector2(1.2, 1.2)
	right_icon.scale = Vector2(1.2, 1.2)
