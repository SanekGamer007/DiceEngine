extends Node
class_name Common

static var magic_scroll_speed_value := 600.0
const engine_version := "0.1"

static var id_to_input: Dictionary[int, String] = {
	0: "left",
	1: "down",
	2: "up",
	3: "right",
}

enum DIFFICULTY {
	EASY,
	NORMAL,
	HARD,
	ERECT,
	NIGHTMARE,
}
static func difficulty_to_string(diff: DIFFICULTY) -> String:
	return DIFFICULTY.keys()[diff].to_lower()

static func string_to_difficulty(diff: String) -> DIFFICULTY:
	return DIFFICULTY.get(diff.to_upper())
