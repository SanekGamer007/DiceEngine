extends Control
var btn_selected: int = 0
var buttons: Array[Control]
var button_preload: PackedScene = preload("res://objects/dice_menu_button/dice_menu_button.tscn")
var transition_in_progress: bool = false

@export var bpm: int = 102
@export var numerator: int = 3
@export var denominator: int = 3

func _ready() -> void:
	MusicManager.play("freaky_menu", 1.0, true, 3.0, false, 3.0)
	Game.bpm = bpm
	Game.numerator = numerator
	Game.denominator = denominator
	var songs: Array[String] = Registry.songs.keys()
	songs.sort()
	if songs.is_empty():
		var menubutton: DiceMenuButton = button_preload.instantiate()
		menubutton.button.text = "NO SONGS FOUND!"
		$DiceMenuContainer.add_child(menubutton)
		buttons.append(menubutton)
		select_button(0)
		return
	for song: String in songs:
		var pretty_name = song.replace("_", " ").to_upper()	
		var menubutton: DiceMenuButton = button_preload.instantiate()
		menubutton.button.text = pretty_name
		menubutton.modulate = Color(1.0, 1.0, 1.0, 0.7)
		$DiceMenuContainer.add_child(menubutton)
		buttons.append(menubutton)
	select_button(0)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_down"):
		unselect_button(btn_selected)
		select_button(btn_selected + 1)
	elif event.is_action_pressed("ui_up"):
		unselect_button(btn_selected)
		select_button(btn_selected - 1)
	elif event.is_action_pressed("ui_back"):
		transition_in_progress = true
		TransitionManager.change_scene_to_file(Registry.menus.get("main"), "fade", 1.0)

func select_button(idx: int) -> void:
	if transition_in_progress:
		return
	idx = posmod(idx, buttons.size())
	btn_selected = idx
	buttons[idx].modulate = Color(1.0, 1.0, 1.0, 1.0)
	buttons[idx].grab_focus()

func unselect_button(idx: int) -> void:
	if transition_in_progress:
		return
	idx = posmod(idx, buttons.size())
	buttons[idx].modulate = Color(1.0, 1.0, 1.0, 0.7)

func _process(delta: float) -> void:
	$DiceMenuContainer.scroll_progress = lerp($DiceMenuContainer.scroll_progress, float(btn_selected), delta * 10)
