extends Node2D
class_name Character

@export var bpm: int = 120
@export var mus_time: float = 0.0
@export var flip_h: bool = false
@export var flip_v: bool = false
@export var bot_play: bool = false
@export var id: int = -1 ## if -1 its set automatically
var crotchet
var step_crotchet
var current_beat

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
	if current_beat != floor(mus_time / crotchet) and $AnimatedSprite2D.animation == "idle":
		$AnimatedSprite2D.play("idle")
	current_beat = floor(mus_time / crotchet)

func _on_note_pressed(id: int, _accuracy: float) -> void:
	print("pressed: ",id)
	$IdleTimer.stop()
	$AnimatedSprite2D.set_frame_and_progress(0, 0.0)
	var anims = ["left", "down", "up", "right"]
	$AnimatedSprite2D.play(anims[id])
	if bot_play:
		$IdleTimer.start()

func _on_note_released(id: int) -> void:
	print("released: ",id)
	$IdleTimer.start()

func _on_idle_timer_timeout() -> void:
	$AnimatedSprite2D.play("idle")
