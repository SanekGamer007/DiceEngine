extends CanvasLayer

var transitions: Dictionary[String, PackedScene]
var current_transition: Transition
signal done

func find_transitions() -> void:
	transitions.clear()
	for transition_name in Registry.transitions:
		var transition = load(Registry.transitions[transition_name])
		transitions[transition_name] = transition

func show_transition(transition_name: String = "fade", duration: float = 1.0) -> void:
	await _show_transition(transition_name, duration)
	done.emit()

func _show_transition(transition_name: String = "fade", duration: float = 1.0) -> void:
	if current_transition:
		push_warning("Only one transition can be started at a time")
		return
	if not transitions.has(transition_name):
		push_error("Transition not found, using fade by default...")
		transition_name = "fade"
	current_transition = transitions[transition_name].instantiate()
	add_child(current_transition)
	current_transition.show_transition(duration)
	await current_transition.done

func hide_transition(duration: float = 1.0) -> void:
	await _hide_transition(duration)
	done.emit()

func _hide_transition(duration: float = 1.0) -> void:
	if not current_transition:
		push_warning("No transition is currently playing.")
		return 
	current_transition.hide_transition(duration)
	await current_transition.done
	current_transition = null

func change_scene_to_file(scene_path: String, transition_name: String = "fade", duration: float = 1.0) -> void:
	if current_transition:
		push_warning("Only one transition can be started at a time")
		done.emit()
		return
	await _show_transition(transition_name, duration / 2.0)
	get_tree().change_scene_to_file(scene_path)
	await get_tree().scene_changed
	await _hide_transition(duration / 2.0)
	done.emit()


func change_scene_to_packed(scene: PackedScene, transition_name: String = "fade", duration: float = 1.0) -> void:
	if current_transition:
		push_warning("Only one transition can be started at a time")
		done.emit()
		return
	await _show_transition(transition_name, duration / 2.0)
	get_tree().change_scene_to_packed(scene)
	await get_tree().scene_changed
	await _hide_transition(duration / 2.0)
	done.emit()

func change_scene_to_node(scene: Node, transition_name: String = "fade", duration: float = 1.0) -> void:
	if current_transition:
		push_warning("Only one transition can be started at a time")
		done.emit()
		return
	await _show_transition(transition_name, duration / 2.0)
	get_tree().change_scene_to_node(scene)
	await get_tree().scene_changed
	await _hide_transition(duration / 2.0)
	done.emit()
