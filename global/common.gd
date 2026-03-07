extends Node
class_name Common

static var magic_scroll_speed_value := 600.0
const engine_version := "0.1"

enum ARROW_DIR {
	LEFT,
	DOWN,
	UP,
	RIGHT
}

enum DIFFICULTY {
	EASY,
	NORMAL,
	HARD,
	ERECT,
	NIGHTMARE,
}


static func id_to_input(dir: ARROW_DIR) -> String:
	return ARROW_DIR.keys()[dir].to_lower()

static func input_to_id(dir: String) -> ARROW_DIR:
	return ARROW_DIR.get(dir.to_upper())

static func difficulty_to_string(diff: DIFFICULTY) -> String:
	return DIFFICULTY.keys()[diff].to_lower()

static func string_to_difficulty(diff: String) -> DIFFICULTY:
	return DIFFICULTY.get(diff.to_upper())
