extends Node

signal mod_loaded(mod_name: String)
signal mod_unloaded(mod_name: String)

const mods_base_paths: Array[String] = ["user://mods/"]

var found_mods: Dictionary[String, Mod]
var enabled_mods: Dictionary[String, Mod]
var default_mod_icon: ImageTexture
var mods_paths: Array[String]


func _ready() -> void:
	default_mod_icon = ImageTexture.create_from_image(Image.load_from_file("res://mod_icon.png"))
	default_mod_icon.set_size_override(Vector2i(32, 32))
	mods_paths.append(OS.get_executable_path().get_base_dir().path_join("mods"))
	if OS.has_feature("editor"):
		mods_paths.append("res://mods/")
	find_mods()
	load_mod("internal", true)


func find_mods() -> void:
	found_mods.clear()
	found_mods.assign(_find_mods())


func load_mod(mod: String, reinit: bool = false) -> void:
	if not found_mods.has(mod):
		push_error("Mod not found.")
		return
	var found_mod: Mod = found_mods.get(mod)
	if not found_mod:
		push_error("Mod not found.")
		return
	var mod_json_path: String = found_mod.path
	var mod_data: Dictionary = found_mod.data
	var mod_pcks: Array[String]
	mod_pcks.assign(mod_data.get("pck", [""]))
	
	var mod_version: String = mod_data.get("version", Common.get_version())
	var mod_version_type: int = int(mod_data.get("version_type", Common.VERSION_TYPE.MATCH))
	var version_status: Common.VERSION_TYPE = Common.validate_version(mod_version)
	var is_valid: bool = false
	match mod_version_type:
		Common.VERSION_TYPE.LOWER:
			is_valid = version_status >= 1
		Common.VERSION_TYPE.MATCH:
			is_valid = version_status == 1
		Common.VERSION_TYPE.HIGHER:
			is_valid = version_status <= 1
	if not is_valid:
		push_error("Mod version configuration does not allow this version of the engine to load it.")
		return
	
	for pck in mod_pcks:
		var mod_path: String = mod_json_path.get_base_dir().path_join(pck)
		if not pck.contains(".pck"):
			if not mod_json_path.contains("res://"):
				push_error("External mods must use the .pck format.")
				return
			Registry._add_paths(_find_modded_assets_paths(mod_path))
		else:
			push_warning("TBD")
			return
			if not FileAccess.file_exists(mod_path):
				push_error(pck, " Not found.")
			ProjectSettings.load_resource_pack(mod_path, true)
			var new_mod_path: String = "res://mods/".path_join(pck)
	
	enabled_mods[mod] = found_mods[mod]
	mod_loaded.emit(mod)
	
	if reinit:
		Registry.rebuild_database()


func unload_mod(mod: String, reinit: bool = false) -> void:
	if not enabled_mods.has(mod):
		return
	var enabled_mod: Mod = enabled_mods[mod]
	if not enabled_mod:
		push_error("Mod not found")
		return
	var mod_data: Dictionary = enabled_mod.data
	var mod_pcks: Array[String]
	mod_pcks.assign(mod_data.get("pck"))
	
	for pck in mod_pcks:
		var mod_path: String = enabled_mod.path.get_base_dir().path_join(pck)
		Registry._remove_paths(_find_modded_assets_paths(mod_path))
	enabled_mods.erase(mod)
	mod_unloaded.emit(mod)
	
	if reinit:
		Registry.rebuild_database()


func _find_mods() -> Dictionary[String, Mod]:
	var newly_found_mods: Dictionary[String, Mod]
	newly_found_mods["internal"] = _get_internal_mod()
	
	for path: String in mods_paths:
		if not DirAccess.dir_exists_absolute(path):
			continue
		var folders = DirAccess.get_directories_at(path)
		for mod_folder: String in folders:
			var new_mod = Mod.new()
			var full_path = path.path_join(mod_folder)
			new_mod.path = full_path.path_join(mod_folder + ".json")
			var mod_info_raw: String = FileAccess.get_file_as_string(new_mod.path)
			new_mod.data = JSON.parse_string(mod_info_raw)
			if not new_mod.data:
				push_error("Failed to parse mod JSON at ", full_path)
				continue
			var mod_id = new_mod.data.get("id", "error")
			if mod_id == "error":
				continue
			var mod_icon_name: String = new_mod.data.get("icon")
			if mod_icon_name:
				var icon_path = full_path.path_join(mod_icon_name)
				var mod_icon = Image.load_from_file(icon_path)
				new_mod.icon = ImageTexture.create_from_image(mod_icon)
				new_mod.icon.set_size_override(Vector2i(32, 32))
			else:
				new_mod.icon = default_mod_icon
			
			newly_found_mods[mod_id] = new_mod
	return newly_found_mods


func _get_internal_mod() -> Mod:
	var internal_json = FileAccess.get_file_as_string("res://internal/internal.json")
	var internal_data = JSON.parse_string(internal_json)
	var internal_mod = Mod.new()
	internal_mod.path = "res://internal/internal.json"
	internal_mod.icon = default_mod_icon
	internal_mod.data = internal_data
	return internal_mod


func _find_modded_assets_paths(mod_path: String) -> Dictionary[String, String]:
	var found_paths: Dictionary[String, String]
	
	var root_paths: PackedStringArray = ResourceLoader.list_directory(mod_path)
	var ui_folder: String = ""
	
	for path in root_paths:
		if not path.ends_with("/"):
			continue
		
		var folder = path.trim_suffix("/")
		var full_path = mod_path.path_join(path)
		
		match folder:
			"characters":
				found_paths["characters"] = full_path
			"menus":
				found_paths["menus"] = full_path
			"music":
				found_paths["music"] = full_path
			"songs":
				found_paths["songs"] = full_path
			"sounds":
				found_paths["sounds"] = full_path
			"stages":
				found_paths["stages"] = full_path
			"ui":
				ui_folder = full_path

	if ui_folder:
		var ui_paths: PackedStringArray = ResourceLoader.list_directory(ui_folder)
		for path in ui_paths:
			if not path.ends_with("/"):
				continue
			
			var folder = path.trim_suffix("/")
			var full_path = ui_folder.path_join(path)
			
			match folder:
				"hp_bars":
					found_paths["hp_bars"] = full_path
				"info_bars":
					found_paths["info_bars"] = full_path
				"noteskins":
					found_paths["noteskins"] = full_path
				"transitions":
					found_paths["transitions"] = full_path
	
	return found_paths


class Mod:
	var path: String
	var icon: ImageTexture
	var data: Dictionary
