@tool
extends EditorProperty
## @desc Inspector property for selecting the animation node,
##			and handles the animation import process.
##

var anim_player: AnimationPlayer
var drop_down := OptionButton.new()

signal animation_updated()

func get_animatesymbol():
	var root = get_tree().edited_scene_root
	return _get_animate_symbols(root)[drop_down.selected]

func _get_animate_symbols(root: Node) -> Array:
	var asNodes := []

	for child in root.get_children():
		asNodes += _get_animate_symbols(child)

	if root is AnimateSymbol:
		asNodes.append(root)

	return asNodes

func _init(_anim_player):
	anim_player = _anim_player

	drop_down.clip_text = true
	# Add the control as a direct child of EditorProperty node.
	add_child(drop_down)
	# Make sure the control is able to retain the focus.
	add_focusable(drop_down)

	drop_down.clear()

func _ready():
	get_items()


func get_items():
	drop_down.clear()

	var root = get_tree().edited_scene_root
	var anim_sprites := _get_animate_symbols(root)

	for i in range(len(anim_sprites)):
		var anim_sprite = anim_sprites[i]

		drop_down.add_item(anim_player.get_path_to(anim_sprite), i)

func convert_symbols():
	var animate_symbol: AnimateSymbol = get_node(get_animatesymbol().get_path())

	var count := 0
	var updated_count := 0
	
	if animate_symbol.atlases.is_empty():
		print("[Dice] AnimateSymbol has no atlases!")
		return
	var processed_anims = {}
	
	for atlas_idx in range(animate_symbol.atlases.size()):
		var atlas = animate_symbol.atlases[atlas_idx]
		if not atlas:
			print("[Dice] Current atlas is invalid!")
			continue
	
		var symbols_string = atlas.get_symbols() 
		var anim_list: PackedStringArray = symbols_string.split(",")
		print(anim_list)
		for anim in anim_list:
			if anim.is_empty():
				printerr("[Dice] Symbols on AnimateSymbol '%s' has an \nsymbol named empty string '', it will be ignored" % animate_symbol.name)
				continue
			
			var updated = add_animation_from_symbol(
					anim_player.get_node(anim_player.root_node).get_path_to(animate_symbol),
					anim,
					animate_symbol,
					atlas_idx,
				)
			
			count += 1
			
			if updated:
				updated_count += 1

	if count - updated_count > 0:
		print("[Dice] Added %d animations!" % [count - updated_count])
	if updated_count > 0:
		print("[Dice] Updated %d animations!" % updated_count)

	emit_signal("animation_updated")

func add_animation_from_symbol(node_path: NodePath, symbol: String, animate_symbol: AnimateSymbol, atlas_idx: int = 0):
	var frame_count
	var fps = animate_symbol.atlases[atlas_idx].get_framerate()
	if animate_symbol.atlases[atlas_idx] is AdobeAtlas:
		frame_count = animate_symbol.atlases[atlas_idx].get_length_of(symbol)
	else:
		frame_count = animate_symbol.atlases[atlas_idx].get_count_filtered(symbol)
	var looping = animate_symbol.loop
	# Determine the total animation duration in seconds. First sum the duration
	# of each frame, then divide duration by FPS to get the length in seconds.
	var duration: float = frame_count / fps

	# We add the converted animation to the [Global] animation library,
	# which corresponding to the empty string "" key
	var global_animation_library: AnimationLibrary
	if anim_player.has_animation_library(&""):
		# The [Global] animation library already exists, so get it
		# The only reason we check has_animation_library then call
		# get_animation_library instead of just checking if get_animation_library
		# returns null, is that get_animation_library causes an error when no
		# library is found.
		global_animation_library = anim_player.get_animation_library(&"")
	else:
		# The [Global] animation library does not exist yet, so create it
		global_animation_library = AnimationLibrary.new()
		anim_player.add_animation_library(&"", global_animation_library)

	# SpriteFrames allow characters ":" and "[" in animation names, but not
	# Animation Player library, so sanitize the name
	var sanitized_anim_name = symbol.replace(":", "_")
	sanitized_anim_name = sanitized_anim_name.replace("[", "_")

	var updated := false
	var animation: Animation = null

	if global_animation_library.has_animation(sanitized_anim_name):
		animation = global_animation_library.get_animation(sanitized_anim_name)

		updated = true
	else:
		animation = Animation.new()
		global_animation_library.add_animation(sanitized_anim_name, animation)

	animation.length = duration

	# SpriteFrames only supports linear looping (not ping-pong),
	# so set loop mode to either None or Linear
	animation.loop_mode = Animation.LOOP_LINEAR if animate_symbol.loop else Animation.LOOP_NONE

	# Remove existing tracks
	var symbol_path := "%s:symbol" % node_path
	var frame_path := "%s:frame" % node_path
	var atlas_path := "%s:atlas_index" % node_path

	var anim_track = animation.find_track(symbol_path, Animation.TYPE_VALUE)
	var frame_track = animation.find_track(frame_path, Animation.TYPE_VALUE)
	var atlas_track = animation.find_track(atlas_path, Animation.TYPE_VALUE)

	var tracks_to_check = [symbol_path, frame_path, atlas_path]
	for path in tracks_to_check:
		var existing_idx = animation.find_track(path, Animation.TYPE_VALUE)
		if existing_idx >= 0:
			animation.remove_track(existing_idx)

	# Add and create tracks

	frame_track = animation.add_track(Animation.TYPE_VALUE, 0)
	anim_track = animation.add_track(Animation.TYPE_VALUE, 1)
	atlas_track = animation.add_track(Animation.TYPE_VALUE, 2)

	animation.track_set_path(anim_track, symbol_path)

	# Use the original animation name from SpriteFrames here,
	# since the track expects a SpriteFrames animation key for the AnimatedSprite2D
	animation.track_insert_key(anim_track, 0, symbol)
	animation.track_insert_key(atlas_track, 0, atlas_idx) 

	animation.track_set_path(frame_track, frame_path)
	animation.track_set_path(atlas_track, atlas_path)

	animation.value_track_set_update_mode(atlas_track, Animation.UPDATE_DISCRETE)
	animation.value_track_set_update_mode(frame_track, Animation.UPDATE_DISCRETE)
	animation.value_track_set_update_mode(anim_track, Animation.UPDATE_DISCRETE)

	# Initialize first sprite key time
	var next_key_time := 0.0

	var spf = 1.0/fps
	
	for i in range(frame_count):
		animation.track_insert_key(frame_track, i * spf, i)

	return updated

func get_tooltip_text():
	return "AnimateSymbol node to import frames from."
