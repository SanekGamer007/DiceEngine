extends Control
class_name Transition

signal done


func show_transition(duration: float = 1.0) -> void:
	done.emit.call_deferred()


func hide_transition(duration: float = 1.0) -> void:
	done.emit.call_deferred()
	queue_free()
