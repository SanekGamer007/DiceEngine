extends Control
class_name Strum

@export var id: int = 0
@export var sprite: SpriteFrames :
	set(spr):
		sprite = spr
		if is_inside_tree():
			$NoteAnimatedSprite2D.sprite_frames = spr
@export var sprite_splash: SpriteFrames :
	set(spr):
		sprite_splash = spr
		var names = spr.get_animation_names()
		for s: String in names:
			splash_nums.append(int(s[s.length() - 1]))
		splash_nums.sort()
		if is_inside_tree():
			$SplashAnimatedSprite2D.sprite_frames = spr
@export var owner_strumline: StrumLine
var action_name: String
var current_notes: Array[Note]
var splash_nums: PackedInt32Array

func _ready() -> void:
	action_name = Common.id_to_input.get(id)
	$NoteAnimatedSprite2D.sprite_frames = sprite
	$NoteAnimatedSprite2D.play("default")

func _input(event: InputEvent) -> void:
	if owner_strumline.bot_play:
		return
	if event.is_action_pressed(action_name):
		if not current_notes.is_empty():
			var accr = 1.0 - (abs(current_notes[0].position.y) / $Area2D/CollisionShape2D.shape.size.y)
			accr = clampf(accr, 0.0, 1.0)
			$NoteAnimatedSprite2D.play("pressed")
			current_notes[0].queue_free()
			current_notes.remove_at(0)
			owner_strumline.note_pressed.emit(id, accr)
			if accr >= 0.9:
				_show_splash()
		else:
			$NoteAnimatedSprite2D.play("nothin")
	if event.is_action_released(action_name):
		if $NoteAnimatedSprite2D.animation != "default" and $NoteAnimatedSprite2D.animation != "pressed":
			$NoteAnimatedSprite2D.play("default")
		else:
			owner_strumline.note_released.emit(id)

func _process(delta: float) -> void:
	if owner_strumline.bot_play:
		if not current_notes.is_empty():
			if current_notes[0].position.y >= 0:
				return
			$NoteAnimatedSprite2D.play("pressed")
			current_notes[0].queue_free()
			current_notes.remove_at(0)
			owner_strumline.note_pressed.emit(id, 1.0)
		return

func _on_note_animated_sprite_2d_animation_finished() -> void:
	if $NoteAnimatedSprite2D.animation == "pressed":
		$NoteAnimatedSprite2D.play("default")


func _on_splash_animated_sprite_2d_animation_finished() -> void:
	$SplashAnimatedSprite2D.visible = false

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area is Note:
		current_notes.append(area)

func _on_area_2d_area_exited(area: Area2D) -> void:
	if area is Note:
		if not current_notes.has(area):
			return
		if current_notes.is_empty():
			return
		var remove_id = current_notes.find(area)
		if remove_id != -1:
			current_notes.remove_at(remove_id)
			owner_strumline.note_missed.emit(id)
		else:
			push_error("damn idk what to tell you.")

func _show_splash() -> void:
	var max_rand = splash_nums[0]
	var min_rand = splash_nums[splash_nums.size() - 1]
	var rand = randi_range(min_rand, max_rand)
	var anim_name: String = Common.id_to_input[id]
	$SplashAnimatedSprite2D.visible = true
	$SplashAnimatedSprite2D.play(anim_name + "_" + str(rand))
