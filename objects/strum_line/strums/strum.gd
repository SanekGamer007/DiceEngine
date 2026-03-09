extends Control
class_name Strum

## This is a mess mostly because huge chunks of the code persisted through major architecture changes.
## Example: Note detection fully on collition to Hybrid of collision and time to fully time based.

@export var direction: Common.ARROW_DIR = Common.ARROW_DIR.LEFT
@export var note_skin: NoteSkinResource :
	set(skin):
		note_skin = skin
		set_note_skin(skin)
@export var owner_strumline: StrumLine
var action_name: String
var current_notes: Array[Note]
var active_sustain: Note = null
var splash_nums: PackedInt32Array

enum ANIM_STATES {
	IDLE,
	NOTHIN,
	PRESSED,
	HOLD,
}
@export var state: ANIM_STATES = ANIM_STATES.IDLE:
	set(new_state):
		state = new_state
		_update_visuals()

func _ready() -> void:
	action_name = Common.id_to_input(direction)
	set_note_skin(note_skin)

func _input(event: InputEvent) -> void:
	if owner_strumline.bot_play:
		return
	if event.is_action_pressed(action_name) and not event.is_echo():
		if not current_notes.is_empty():
			var note = current_notes[0]
			var diff = abs(Game.mus_time - note.time)
			if diff <= Common.judge_ranks["SHIT"][1]:
				var accr = calc_accr(diff)
				accr = clampf(accr, 0.0, 1.0)
				if diff <= Common.judge_ranks["SICK"][1]:
					_show_splash()
				
				if note.length != 0.0:
					state = ANIM_STATES.HOLD
					active_sustain = note
					if not active_sustain.was_pressed:
						active_sustain.was_pressed = true
						owner_strumline.note_pressed.emit(direction, accr)
					active_sustain.hold_hit()
					current_notes.remove_at(0)
				else:
					state = ANIM_STATES.PRESSED
					current_notes.remove_at(0)
					note.queue_free()
					owner_strumline.note_pressed.emit(direction, accr)
			else:
				state = ANIM_STATES.NOTHIN
				if not owner_strumline.ghost_tapping:
					owner_strumline.note_missed.emit(direction)
				return
		else:
			state = ANIM_STATES.NOTHIN
			if not owner_strumline.ghost_tapping:
				owner_strumline.note_missed.emit(direction)
			return
	if event.is_action_released(action_name):
		if not current_notes.is_empty() or ANIM_STATES.IDLE:
			owner_strumline.note_released.emit(direction)


func _process(delta: float) -> void:
	if not current_notes.is_empty():
		var note = current_notes[0]
		if not note:
			return
		if Game.mus_time > note.time + Common.judge_ranks["SHIT"][1]:
			current_notes.remove_at(0)
			if not note.was_pressed:
				owner_strumline.note_missed.emit(direction)
	if owner_strumline.bot_play:
		if not current_notes.is_empty() and not active_sustain:
			var note = current_notes[0]
			if Game.mus_time >= note.time:
				if note.length != 0.0:
					active_sustain = note
					active_sustain.was_pressed = true
					active_sustain.hold_hit()
					state = ANIM_STATES.HOLD
					#current_notes.remove_at(0)
					owner_strumline.note_pressed.emit(direction, 1.0)
				else:
					state = ANIM_STATES.PRESSED
					current_notes[0].queue_free()
					current_notes.remove_at(0)
					owner_strumline.note_pressed.emit(direction, 1.0)
	if active_sustain:
		var note_end_time = active_sustain.time + active_sustain.length
		if not owner_strumline.bot_play and not Input.is_action_pressed(action_name):
			active_sustain = null
			state = ANIM_STATES.IDLE
			return
		if Game.mus_time >= note_end_time:
			owner_strumline.note_released.emit(direction) 
			state = ANIM_STATES.NOTHIN
			active_sustain.end_hit()
			active_sustain = null
			return
		else:
			owner_strumline.note_sustained.emit(direction)
			active_sustain.update_clip()
	
	if state == ANIM_STATES.NOTHIN:
		if not Input.is_action_pressed(action_name):
			state = ANIM_STATES.IDLE

func _update_visuals() -> void:
	match state:
		ANIM_STATES.IDLE:
			$NoteAnimatedSprite2D.play("default")
		ANIM_STATES.NOTHIN:
			$NoteAnimatedSprite2D.play("nothin")
		ANIM_STATES.PRESSED:
			$NoteAnimatedSprite2D.play("pressed")
		ANIM_STATES.HOLD:
			$NoteAnimatedSprite2D.play("pressed_hold")

func _on_note_animated_sprite_2d_animation_finished() -> void:
	if state == ANIM_STATES.PRESSED and not Input.is_action_pressed(action_name):
		state = ANIM_STATES.IDLE
	elif state == ANIM_STATES.PRESSED and Input.is_action_pressed(action_name):
		state = ANIM_STATES.NOTHIN

func _on_splash_animated_sprite_2d_animation_finished() -> void:
	$SplashAnimatedSprite2D.visible = false

func _show_splash() -> void:
	var max_rand = splash_nums[0]
	var min_rand = splash_nums[splash_nums.size() - 1]
	var rand = randi_range(min_rand, max_rand)
	var anim_name: String = Common.id_to_input(direction)
	$SplashAnimatedSprite2D.visible = true
	$SplashAnimatedSprite2D.play(anim_name + "_" + str(rand))

func calc_accr(diff: float) -> float:
	var rank_name = Common.secs_to_rank(diff)
	return Common.rank_to_accr(rank_name)

func set_note_skin(skin: NoteSkinResource) -> void:
	if not is_inside_tree():
		return
	if not skin:
		return
	var names = skin.splsh_frames.get_animation_names()
	for s: String in names:
		splash_nums.append(int(s[s.length() - 1]))
	splash_nums.sort()
	$NoteAnimatedSprite2D.sprite_frames = skin.note_frames[direction]
	$NoteAnimatedSprite2D.scale = skin.note_scale
	$SplashAnimatedSprite2D.sprite_frames = skin.splsh_frames
	$SplashAnimatedSprite2D.scale = skin.splsh_scale
	if skin.g_is_pixel:
		$NoteAnimatedSprite2D.texture_filter = TextureFilter.TEXTURE_FILTER_NEAREST
		$SplashAnimatedSprite2D.texture_filter = TextureFilter.TEXTURE_FILTER_NEAREST
	else:
		$NoteAnimatedSprite2D.texture_filter = TextureFilter.TEXTURE_FILTER_PARENT_NODE
		$SplashAnimatedSprite2D.texture_filter = TextureFilter.TEXTURE_FILTER_PARENT_NODE
	
