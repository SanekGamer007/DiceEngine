extends Node2D

func _ready() -> void:
	$BG/PhillyTraffic/Loop.play("loop")

func _on_loop_animation_finished(_anim_name: StringName) -> void:
	$BG/PhillyTraffic/Loop.play("loop")
