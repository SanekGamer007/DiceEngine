extends Control
class_name StrumLine

var note_preload = preload("res://objects/note/note.tscn")

@export var note_skins: Array[Texture2D]

@export var bot_play: bool = false
@export var ghost_tapping: bool = false
@export var scroll_speed: float = 1.0
@export var strums: Array[Strum]
@export var character: Character
@export var notes: Array[Dictionary]
@export var id: int
@export var mus_time: float = 0.0
@export var bpm: int = 120

var cleaner_pos: float
var next_note_index: int = 0

signal init_done
signal note_pressed(direction: Common.ARROW_DIR, accuracy: float)
signal note_released(direction: Common.ARROW_DIR)
signal note_missed(direction: Common.ARROW_DIR)
signal note_ghosted(direction: Common.ARROW_DIR)

func _ready() -> void:
	Input.set_use_accumulated_input(false)
	set_process(false)

func _process(delta: float) -> void:
	cleaner_pos = global_position.y - 120
	var dist = get_viewport_rect().size.y / get_viewport().get_camera_2d().zoom.y / scale.y
	var spawn_time_ahead = dist / (scroll_speed * Common.magic_scroll_speed_value)
	if character:
		character.mus_time = mus_time
	
	while notes.size() > next_note_index and mus_time >= notes[next_note_index].t - spawn_time_ahead:
		var current_note = notes[next_note_index]
		var strum: Strum = $Strums.get_child(current_note.i)
		var spawn_location = strum.get_node("Notes")
		var note: Note = note_preload.instantiate()
		note.direction = int(current_note.i) as Common.ARROW_DIR
		note.scroll_speed = scroll_speed
		note.position.y = (current_note.t - mus_time) * (scroll_speed * Common.magic_scroll_speed_value)
		note.sprite = note_skins[note.direction]
		note.clean_pos = cleaner_pos
		spawn_location.add_child(note)
		next_note_index += 1

func _on_notes_loaded() -> void:
	notes.sort_custom(func(a, b): return a.t < b.t)
	for child: Strum in $Strums.get_children():
		strums.append(child)
		child.owner_strumline = self
	if character:
		note_pressed.connect(character._on_note_pressed)
		note_released.connect(character._on_note_released)
		init_done.connect(character._on_init_done)
		character.bpm = bpm
		character.bot_play = bot_play
	set_process(true)
	init_done.emit()
