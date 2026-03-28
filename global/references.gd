extends Node

var camera: Camera2D
var stage: Node
var hud: Hud
var play_scene: PlayScene
var characters: Array[Character]
var strumlines: Array[StrumLine]

func clear() -> void:
	camera = null
	stage = null
	hud = null
	play_scene = null
	characters.clear()
	strumlines.clear()
