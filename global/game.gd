extends Node

var mus_time: float
var bpm: float = 120 :
	set(amount):
		bpm = amount
		crotchet = 60.0 / amount
		step_crotchet = crotchet / 4.0
var current_beat: int = 0 
var crotchet = 60.0 / bpm
var step_crotchet = crotchet / 4.0
