extends Node2D
class_name Character

@export var bpm: int = 120
@export var flip_h: bool = false
@export var flip_v: bool = false
@export var bot_play: bool = false
@export var id: int = -1 ## if -1 its set automatically
@export_category("Character Preferences")
@export var loop_time_start: float = 0.0
@export var loop_time_end: float = 0.2
@export var loop_speed: float = 1.5
@export var icon: Array[Texture2D] ## First one is losing, second one is normal, third one is dominating
@export var icon_progress: Array[float] = [20.0, 80.0] ## First one is losing, Second one is dominating
@export var filtering: TextureFilter = TextureFilter.TEXTURE_FILTER_PARENT_NODE
@export_color_no_alpha var hp_color: Color = Color.WHITE
var can_loop: bool = true

const anims = ["left", "down", "up", "right"]
const anims_missed = ["left_miss", "down_miss", "up_miss", "right_miss"]

func _ready() -> void:
	$AnimationPlayer.play("idle", 0.0, true)
	$AnimatedSprite2D.flip_h = flip_h
	$AnimatedSprite2D.flip_v = flip_v
	set_process(false)

func _on_init_done() -> void:
	set_process(true)

func _process(delta: float) -> void:
	if Game.current_beat != floor(Game.mus_time / Game.crotchet) and $AnimationPlayer.current_animation == "idle":
		$AnimationPlayer.play("idle")

func _on_note_pressed(direction: Common.ARROW_DIR, _accuracy: float) -> void:
	$IdleTimer.stop()
	$AnimationPlayer.seek(0.0, true)
	$AnimationPlayer.play(anims[direction])
	if bot_play:
		$IdleTimer.start()

func _on_note_sustained(direction: Common.ARROW_DIR) -> void:
	if not can_loop:
		return
	$IdleTimer.stop()
	$AnimationPlayer.speed_scale = loop_speed
	$AnimationPlayer.play_section_backwards(anims[direction], loop_time_start, loop_time_end)
	can_loop = false

func _on_note_released(direction: Common.ARROW_DIR) -> void:
	can_loop = false 
	if $AnimationPlayer.speed_scale != 1.0:
		$AnimationPlayer.play(anims[direction])
		$AnimationPlayer.speed_scale = 1.0
	$IdleTimer.start()

func _on_note_missed(direction: Common.ARROW_DIR):
	$AnimationPlayer.seek(0.0, true)
	$AnimationPlayer.play(anims_missed[direction])
	$IdleTimer.start()

func _on_idle_timer_timeout() -> void:
	$AnimationPlayer.speed_scale = 1.0
	$AnimationPlayer.play("idle")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if not can_loop and $AnimationPlayer.speed_scale != 1.0:
		can_loop = true
	else:
		$AnimationPlayer.speed_scale = 1.0
		can_loop = true
		$IdleTimer.start()
