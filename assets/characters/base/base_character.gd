extends Node2D
class_name Character

@export var bpm: int = 120
@export var flip_h: bool = false
@export var flip_v: bool = false
@export var bot_play: bool = false
@export var id: int = -1 ## if -1 its set automatically
@export var loop_frames: int = 4
@export var loop_speed: float = 1.5
var crotchet
var step_crotchet
var current_beat
var can_loop: bool = true

const anims = ["left", "down", "up", "right"]
const anims_missed = ["left_miss", "down_miss", "up_miss", "right_miss"]

func _ready() -> void:
	$AnimatedSprite2D.play("idle", 0.0, true)
	$AnimatedSprite2D.flip_h = flip_h
	$AnimatedSprite2D.flip_v = flip_v
	set_process(false)

func _on_init_done() -> void:
	crotchet = 60.0 / bpm
	step_crotchet = crotchet / 4.0
	$IdleTimer.wait_time = crotchet
	set_process(true)

func _process(delta: float) -> void:
	if current_beat != floor(Game.mus_time / crotchet) and $AnimatedSprite2D.animation == "idle":
		$AnimatedSprite2D.play("idle")
	current_beat = floor(Game.mus_time / crotchet)

func _on_note_pressed(direction: Common.ARROW_DIR, _accuracy: float) -> void:
	$IdleTimer.stop()
	$AnimatedSprite2D.set_frame_and_progress(0, 0.0)
	$AnimatedSprite2D.play(anims[direction])
	if bot_play:
		$IdleTimer.start()

func _on_note_sustained(direction: Common.ARROW_DIR) -> void:
	if not can_loop:
		return
	$IdleTimer.stop()
	$AnimatedSprite2D.speed_scale = loop_speed
	$AnimatedSprite2D.play_backwards(anims[direction])
	$AnimatedSprite2D.set_frame(loop_frames)
	can_loop = false

func _on_note_released(direction: Common.ARROW_DIR) -> void:
	can_loop = false 
	if $AnimatedSprite2D.speed_scale != 1.0:
		$AnimatedSprite2D.play(anims[direction])
		$AnimatedSprite2D.speed_scale = 1.0
	$IdleTimer.start()

func _on_note_missed(direction: Common.ARROW_DIR):
	$AnimatedSprite2D.set_frame_and_progress(0, 0.0)
	$AnimatedSprite2D.play(anims_missed[direction])
	$IdleTimer.start()

func _on_idle_timer_timeout() -> void:
	$AnimatedSprite2D.speed_scale = 1.0
	$AnimatedSprite2D.play("idle")

func _on_animated_sprite_2d_animation_finished() -> void:
	if not can_loop and $AnimatedSprite2D.speed_scale != 1.0:
		can_loop = true
	else:
		$AnimatedSprite2D.speed_scale = 1.0
		can_loop = true
		$IdleTimer.start()
