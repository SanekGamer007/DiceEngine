extends Control

@export var splashes: Dictionary[String, Array] = {
	"credit": [
		"ORIGINAL\n\"FULL ASS\" GAME--\nBY FUNKIN CREW",
	],
	"newgrounds": [
		"IN ASSOCIATION\nWITH--\nNEWGROUNDS",
	],
	"shit": [
		"THIS SHIT--\nSUCKS ASS\nLMAO",
		"GOOD CODE--\nWHAT'S THAT",
		"WHO EVEN NEED'S EVENTS--\nTHEY'RE DISTRACTING",
		"FUCK THE--\nCAMERA",
		"MY BALLS--\nITCH",
		"THIS WAS ORIGINALLY--\nJUST A SMALL SIDE PROJECT",
		"IDK WHAT TO--\nPUT HERE",
		"5 BILLION DOLLARS--\nFOR CRACK",
		"THIS IS--\nTHE WORST ENGINE\nKNOWN TO MAN",
	],
	"last": [
		"FRIDAY--\nNIGHT--\nFUNKIN",
		"DICE--\nFUNKIN'--\nENGINE",
	],
}
@export var bpm: int = 102
@export var numerator: int = 3
@export var denominator: int = 3
@export var richtextlabel: RichTextLabel
var last_audio_pos: float = 0.0

var tween: Tween
var strings: Array[String]
var transition_in_progress: bool = false


func _ready() -> void:
	MusicManager.play("freaky_menu", 1.0, true, 3.0, false, 3.0)
	$TitleScreen/Start/Start.play("Press Enter to Begin")
	Game.bpm = bpm
	Game.numerator = numerator
	Game.denominator = denominator
	Game.beat.connect(_on_beat)
	for splash: String in splashes:
		var splash_size = splashes[splash].size()
		var rng = randi_range(0, splash_size - 1)
		strings.append(splashes[splash][rng])
	if Game.seen_intro:
		skip_intro()


func _process(delta: float) -> void:
	Game.mus_time += delta
	Game.current_beat = floor(Game.mus_time / Game.crotchet)
	var new_measure = floori(Game.current_beat / Game.numerator)
	if new_measure != Game.current_measure:
		Game.current_measure = new_measure


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_back"):
		get_tree().quit()
	if event.is_action_pressed("confirm") or \
	(event is InputEventMouseButton and \
		event.pressed and \
		event.button_index == MOUSE_BUTTON_LEFT ):
		if transition_in_progress:
			return
		if not Game.seen_intro:
			skip_intro()
		else:
			transition_in_progress = true
			$TitleScreen/Start/Start.play("ENTER PRESSED")
			$TitleScreen/Start/ConfirmSound.play()
			white_flash()
			await $TitleScreen/Start/ConfirmSound.finished
			TransitionManager.change_scene_to_file(Registry.menus.get("main"), "fade", 1.0)


func _on_beat(beat: int) -> void:
	if Game.seen_intro:
		return
	match beat:
		1:
			var org_text: String = strings[0]
			var text = org_text.split("--")[0]
			richtextlabel.text += text
		3:
			var org_text: String = strings[0]
			var text = org_text.split("--")[1]
			richtextlabel.text += text
		4:
			richtextlabel.text = ""
		5:
			var org_text: String = strings[1]
			var text = org_text.split("--")[0]
			richtextlabel.text += text
		7:
			var org_text: String = strings[1]
			var text = org_text.split("--")[1]
			richtextlabel.text += text
			$Intro/Newgrounds.visible = true
		8:
			richtextlabel.text = ""
			$Intro/Newgrounds.visible = false
		9:
			var org_text: String = strings[2]
			var text = org_text.split("--")[0]
			richtextlabel.text += text
		11:
			var org_text: String = strings[2]
			var text = org_text.split("--")[1]
			richtextlabel.text += text
		12:
			richtextlabel.text = ""
		13:
			var org_text: String = strings[3]
			var text = org_text.split("--")[0]
			richtextlabel.text += text
		14:
			var org_text: String = strings[3]
			var text = org_text.split("--")[1]
			richtextlabel.text += text
		15:
			var org_text: String = strings[3]
			var text = org_text.split("--")[2]
			richtextlabel.text += text
		16:
			skip_intro()


func skip_intro() -> void:
	if not Game.seen_intro:
		$TitleScreen/ColorRect.visible = true
		white_flash()
	Game.seen_intro = true
	$Intro.visible = false
	$TitleScreen.visible = true


func white_flash() -> void:
	if tween:
		tween.kill()
	tween = create_tween()
	$TitleScreen/ColorRect.visible = true
	$TitleScreen/ColorRect.modulate = Color.WHITE
	tween.tween_property($TitleScreen/ColorRect, "modulate", Color(1.0, 1.0, 1.0, 0.0), 1)
