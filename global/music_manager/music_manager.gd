extends Node
var current_song: String = ""
var tween: Tween

func play(music: String, volume: float = 1.0, fade_in: bool = true, fade_in_duration: float = 1.0, fade_out: bool = true, fade_out_duration: float = 1.0) -> void:
	if current_song == music:
		return
	if current_song == "":
		fade_out = false
	var music_path: String = Registry.music.get(music)
	if not ResourceLoader.exists(music_path):
		push_error("Music not found.")
		return
	var mus: AudioStream = load(music_path)
	if fade_in or fade_out:
		if tween:
			tween.kill()
		tween = create_tween()
		if fade_out:
			tween.tween_property($AudioStreamPlayer, "volume_linear", 0.0, fade_out_duration)
		tween.tween_callback(func(): 
			$AudioStreamPlayer.stream = mus 
			$AudioStreamPlayer.play() 
			$AudioStreamPlayer.volume_linear = 0.0 if fade_in else volume
		)
		if fade_in:
			tween.tween_property($AudioStreamPlayer, "volume_linear", volume, fade_in_duration)
	else:
		if tween:
			tween.kill()
		$AudioStreamPlayer.volume_linear = volume
		$AudioStreamPlayer.stream = mus
		$AudioStreamPlayer.play()
	current_song = music

func stop(fade_out: bool = true, fade_out_duration: float = 3.0) -> void:
	if fade_out:
		if tween:
			tween.kill()
		tween = create_tween()
		tween.tween_property($AudioStreamPlayer, "volume_linear", 0.0, fade_out_duration)
		tween.tween_callback(func(): 
			$AudioStreamPlayer.stop()
			)
		current_song = ""
		return
	current_song = ""
	$AudioStreamPlayer.stop()
