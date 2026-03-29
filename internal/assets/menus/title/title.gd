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
@export var player: AudioStreamPlayer
@export var richtextlabel: RichTextLabel
var last_audio_pos: float = 0.0

var strings: Array[String]


func _ready() -> void:
	player.stream = load(Registry.music.get("freaky_menu"))
	player.play()
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
	if Input.is_action_just_pressed("confirm"):
		if not Game.seen_intro:
			skip_intro()
		else:
			set_process(false)
			$TitleScreen/Start/Start.play("ENTER PRESSED")
			$TitleScreen/Start/ConfirmSound.play()
			await $TitleScreen/Start/ConfirmSound.finished
			get_tree().change_scene_to_file(Registry.menus.get("freeplay_proto"))


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
		var tween: Tween = create_tween()
		tween.tween_property($TitleScreen/ColorRect, "modulate", Color(1.0, 1.0, 1.0, 0.0), 1)
	Game.seen_intro = true
	$Intro.visible = false
	$TitleScreen.visible = true
