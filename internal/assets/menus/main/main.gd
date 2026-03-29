extends Control

var btn_selected: int = 0
var buttons: Array[Control]
var anim_map: Dictionary[int, Array] = {
	0: ["storymode idle", "storymode selected"],
	1: ["freeplay idle", "freeplay selected"],
	2: ["options idle", "options selected"],
	3: ["credits idle", "credits selected"],
}

var location_map: Dictionary[int, String] = {
	0: "",
	1: "res://internal/assets/menus/freeplay_proto/freeplay_proto.tscn",
	2: "",
	3: "",
}
var transition_in_progress: bool = false
var transition_location: String = ""


func _ready() -> void:
	for child in $Buttons.get_children():
		if child is Control:
			buttons.append(child)
			continue


func _input(event: InputEvent) -> void:
	if transition_in_progress:
		return
	if event.is_action_pressed("ui_down"):
		select_button(btn_selected + 1)
	elif event.is_action_pressed("ui_up"):
		select_button(btn_selected - 1)
	elif event.is_action_pressed("ui_accept"):
		press_button(btn_selected)


func _process(delta: float) -> void:
	$Camera2D.offset.y = lerp($Camera2D.offset.y, float(btn_selected) * 12, delta * 4)


func select_button(idx: int) -> void:
	idx = posmod(idx, buttons.size())
	buttons[btn_selected].get_node("AnimationPlayer").play(anim_map[btn_selected][0])
	btn_selected = idx
	buttons[idx].get_node("AnimationPlayer").play(anim_map[idx][1])


func press_button(idx: int) -> void:
	var location: String = location_map[idx]
	if location == "":
		OS.alert("Not implemented.", "Sorry!")
		return
	transition_in_progress = true
	transition_location = location
	$ConfirmSound.play()
	var tween = create_tween().set_loops(3)
	var tween_btn = create_tween().set_loops()
	tween_btn.tween_property(buttons[idx], "visible", false, 0.05)
	tween_btn.tween_property(buttons[idx], "visible", true, 0.05)
	tween.tween_property($Parallax2D/BG, "visible", false, 0.1)
	tween.tween_property($Parallax2D/BG, "visible", true, 0.1)
	await tween.finished
	TransitionManager.change_scene_to_file(transition_location, "fade", 1.0)
