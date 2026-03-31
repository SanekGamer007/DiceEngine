extends Node2D
class_name Character

@export_category("Character Preferences")
## First field is internal animation name, second is animation name in animation player.
## Required if you use sparrow or atlas, optional if png sequence.
@export var export_anim_map: Dictionary[String, String] 
@export var loop_time_start: float = 0.0 ## from end
@export var loop_time_end: float = 0.2 ## from end
@export var loop_speed: float = 1.5
@export var icon: PackedScene

## Required for any character to implement in any way.
const anims = ["idle", "left", "down", "up", "right", "left_miss", "down_miss", "up_miss", "right_miss"]

enum STATES {
	IDLE,
	NOTE,
	MISS,
	HOLD,
	SPECIAL,
}

var flip_h: bool = false :
	set(flip):
		flip_h = flip
		if is_inside_tree():
			_set_flip_h()
var flip_v: bool = false:
	set(flip):
		flip_v = flip
		if is_inside_tree():
			_set_flip_v()
var can_loop: bool = true
var note_direction: Common.ARROW_DIR
var anim_map: Dictionary[String, String] # made on runtime
var state: STATES = STATES.IDLE


func _ready() -> void:
	set_process(false)
	var found_anims = $AnimationPlayer.get_animation_list()
	anim_map = export_anim_map
	for anim in anims:
		if anim in export_anim_map:
			continue
		elif anim in found_anims:
			anim_map[anim] = anim
		else:
			push_warning("Required animation ", anim, " not found in the character ", name, ".")
	_set_flip_h()
	_set_flip_v()
	Game.beat.connect(_on_game_beat)

func _on_init_done() -> void:
	set_process(true)

func _process(_delta: float) -> void:
	match state:
		STATES.IDLE:
			_handle_idle_state()
		STATES.NOTE:
			_handle_note_state()
		STATES.MISS:
			_handle_miss_state()
		STATES.HOLD:
			_handle_hold_state()
		STATES.SPECIAL:
			_handle_special_state()

func _handle_idle_state() -> void:
	pass

func _handle_note_state() -> void:
	pass

func _handle_miss_state() -> void:
	pass

func _handle_hold_state() -> void:
	if $AnimationPlayer.is_playing():
		can_loop = false
	else:
		can_loop = true

func _handle_special_state() -> void:
	pass


func _set_state(new_state: STATES) -> void:
	var anim_name = Common.id_to_input(note_direction)
	match state: # state exit
		STATES.HOLD:
			if new_state != STATES.HOLD:
				$AnimationPlayer.speed_scale = 1.0
				$AnimationPlayer.play(anim_map[anim_name])
	match new_state: # state enter
		STATES.IDLE:
			pass
		STATES.NOTE:
			$AnimationPlayer.speed_scale = 1.0
			$AnimationPlayer.play(anim_map[anim_name])
			$AnimationPlayer.seek(0.0, true)
			$IdleTimer.start()
		STATES.MISS:
			$AnimationPlayer.speed_scale = 1.0
			$AnimationPlayer.play(anim_map[anim_name + "_miss"])
			$AnimationPlayer.seek(0.0, true)
			$IdleTimer.start()
		STATES.HOLD:
			$AnimationPlayer.stop()
	state = new_state


func _on_note_pressed(direction: Common.ARROW_DIR, _accr: float) -> void:
	note_direction = direction
	_set_state(STATES.NOTE)

func _on_note_missed(direction: Common.ARROW_DIR) -> void:
	note_direction = direction
	_set_state(STATES.MISS)

func _on_note_sustained(direction: Common.ARROW_DIR) -> void:
	note_direction = direction
	if not state == STATES.HOLD:
		_set_state(STATES.HOLD)
	$IdleTimer.start()
	if can_loop:
		var anim_name = Common.id_to_input(note_direction)
		$AnimationPlayer.speed_scale = loop_speed
		$AnimationPlayer.play_section_backwards(anim_map[anim_name], loop_time_start, loop_time_end)
		can_loop = false

func _on_note_released(_direction: Common.ARROW_DIR) -> void:
	if state == STATES.HOLD:
		$IdleTimer.start()
	elif $IdleTimer.is_stopped() and state != STATES.IDLE:
		$IdleTimer.start()

func _on_idle_timer_timeout() -> void:
	_set_state(STATES.IDLE)

func _on_game_beat(_beat: int) -> void:
	if state == STATES.IDLE:
		$AnimationPlayer.play(anim_map["idle"])

func _on_bpm_changed(bpm: int) -> void:
	$IdleTimer.wait_time = 60.0 / bpm

func _set_flip_h():
	$Sprites.scale.x = abs($Sprites.scale.x) * (-1 if flip_h else 1)

func _set_flip_v():
	$Sprites.scale.y = abs($Sprites.scale.y) * (-1 if flip_v else 1)
