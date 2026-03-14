extends Node

var camera: Camera2D
var stage: Node
var hud: CanvasLayer
var controller: PlayScene
var characters: Array[Character]
var strumlines: Array[StrumLine]

func clear() -> void:
	camera = null
	stage = null
	hud = null
	controller = null
	characters.clear()
	strumlines.clear()
