extends Control
class_name StrumLine

var note_preload = preload("res://objects/note/note.tscn")

@export var note_skin: NoteSkinResource :
	set(skin):
		note_skin = skin
		set_note_skin(skin)

@export var bot_play: bool = false
@export var ghost_tapping: bool = false
@export var scroll_speed: float = 1.0
@export var strums: Array[Strum]
@export var character: Character :
	set(c):
		_disconnect_signals(c)
		character = c
		if is_inside_tree():
			_connect_signals()
@export var notes: Array[Dictionary]
@export var id: int
@export var bpm: int = 120

var cleaner_pos: float
var next_note_index: int = 0

signal init_done
signal note_pressed(direction: Common.ARROW_DIR, accuracy: float)
signal note_released(direction: Common.ARROW_DIR)
signal note_missed(direction: Common.ARROW_DIR)
#signal note_ghosted(direction: Common.ARROW_DIR)
signal note_sustained(direction: Common.ARROW_DIR)

func _ready() -> void:
	Input.set_use_accumulated_input(false)
	set_note_skin(note_skin)
	set_process(false)

func _process(_delta: float) -> void:
	cleaner_pos = global_position.y - 120
	var dist = get_viewport_rect().size.y / get_viewport().get_camera_2d().zoom.y / scale.y
	var spawn_time_ahead = dist / (scroll_speed * Common.magic_scroll_speed_value)
	
	while notes.size() > next_note_index and Game.mus_time >= notes[next_note_index].t - spawn_time_ahead:
		var current_note = notes[next_note_index]
		var strum: Strum = $Strums.get_child(current_note.i)
		var spawn_location = strum.get_node("Notes")
		var note: Note = note_preload.instantiate()
		note.direction = int(current_note.i) as Common.ARROW_DIR
		note.time = current_note.t
		note.length = current_note.get("l", 0.0)
		note.scroll_speed = scroll_speed
		note.position.y = (current_note.t - Game.mus_time) * (scroll_speed * Common.magic_scroll_speed_value)
		note.note_skin = note_skin
		note.clean_pos = cleaner_pos
		strum.current_notes.append(note)
		spawn_location.add_child(note)
		next_note_index += 1

func _on_loading_complete() -> void:
	notes.sort_custom(func(a, b): return a.t < b.t)
	for strum: Strum in $Strums.get_children():
		strums.append(strum)
		strum.owner_strumline = self
		strum.note_skin = note_skin
	if character:
		_connect_signals()
	set_process(true)
	init_done.emit()

func _disconnect_signals(old_character: Character) -> void:
	if note_pressed.is_connected(old_character._on_note_pressed):
		note_pressed.disconnect(old_character._on_note_pressed)
	if note_released.is_connected(old_character._on_note_released):
		note_released.disconnect(old_character._on_note_released)
	if note_sustained.is_connected(old_character._on_note_sustained):
		note_sustained.disconnect(old_character._on_note_sustained)
	if note_missed.is_connected(old_character._on_note_missed):
		note_missed.disconnect(old_character._on_note_missed)
	if init_done.is_connected(old_character._on_init_done):
		init_done.disconnect(old_character._on_init_done)

func _connect_signals() -> void:
	if not note_pressed.is_connected(character._on_note_pressed):
		note_pressed.connect(character._on_note_pressed)
	if not note_released.is_connected(character._on_note_released):
		note_released.connect(character._on_note_released)
	if not note_sustained.is_connected(character._on_note_sustained):
		note_sustained.connect(character._on_note_sustained)
	if not note_missed.is_connected(character._on_note_missed):
		note_missed.connect(character._on_note_missed)
	if not init_done.is_connected(character._on_init_done):
		init_done.connect(character._on_init_done)

func set_note_skin(skin: NoteSkinResource) -> void:
	if not is_inside_tree():
		return
	if not skin:
		return
	$Strums["theme_override_constants/separation"] = skin.g_separation
