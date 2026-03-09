extends Node
class_name Common

const magic_scroll_speed_value := 600.0
const engine_name := "Dice Engine"
const engine_major := "0"
const engine_minor := "3"
const engine_hotfix := "0"


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

static var judge_ranks: Dictionary[String, Array] = { # NAME: SCORE, TIME, ACCURACY AWARD
	"SICK": [350, 0.037, 1.0],
	"GOOD": [200, 0.075, 0.75],
	"BAD": [100, 0.115, 0.45],
	"SHIT": [50, 0.180, 0.25],
	"MISS": [0, 999, 0.0],
}

static func id_to_input(dir: ARROW_DIR) -> String:
	return ARROW_DIR.keys()[dir].to_lower()

static func input_to_id(dir: String) -> ARROW_DIR:
	return ARROW_DIR.get(dir.to_upper())

static func difficulty_to_string(diff: DIFFICULTY) -> String:
	return DIFFICULTY.keys()[diff].to_lower()

static func string_to_difficulty(diff: String) -> DIFFICULTY:
	return DIFFICULTY.get(diff.to_upper())

static func secs_to_rank(secs: float) -> String:
	var abs_secs: float = abs(secs)
	for rank in judge_ranks.keys():
		if abs_secs <= judge_ranks[rank][1]:
			return rank
	return "MISS"

static func accr_to_rank(accuraccy: float) -> String:
	var abs_accuraccy: float = abs(accuraccy)
	for rank in judge_ranks.keys():
		if abs_accuraccy >= judge_ranks[rank][2]:
			return rank
	return "MISS"

static func rank_to_accr(rank: String) -> float:
	var rankarray = judge_ranks.get(rank, [])
	if not rankarray:
		return 0.0
	return rankarray[2]

static func get_version() -> String:
	return engine_major + "." + engine_minor + "." + engine_hotfix
