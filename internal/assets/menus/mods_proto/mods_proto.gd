extends Control

func _ready() -> void:
	MusicManager.play("freaky_menu", 1.0, true, 3.0, false, 3.0)
	$VBoxContainer/HBoxContainer/Label.text = Common.engine_name + " v" + Common.get_version() + "\nFreeplay\nWIP"
	$VBoxContainer/HBoxContainer2/VBoxContainer/ItemList.clear()
	for i in ModManager.found_mods.size():
		var mod = ModManager.found_mods.keys()[i]
		var mod_icon = ModManager.found_mods.get(mod).get("icon")
		$VBoxContainer/HBoxContainer2/VBoxContainer/ItemList.add_item(mod, mod_icon)
		if mod == "internal":
			$VBoxContainer/HBoxContainer2/VBoxContainer/ItemList.set_item_disabled(i, true)
	for mod in ModManager.enabled_mods:
		var idx = find_item_in_itemlist($VBoxContainer/HBoxContainer2/VBoxContainer/ItemList, mod)
		print(idx)
		$VBoxContainer/HBoxContainer2/VBoxContainer/ItemList.select(idx, false)


func _on_button_pressed() -> void:
	var selected_mods: PackedInt32Array = $VBoxContainer/HBoxContainer2/VBoxContainer/ItemList.get_selected_items()
	print(selected_mods)
	
	for i in ModManager.enabled_mods.size():
		if ModManager.enabled_mods.keys()[i] == "internal":
			continue
		ModManager.unload_mod(ModManager.enabled_mods.keys()[i])
	
	var mods_keys = ModManager.found_mods.keys()
	
	for i in selected_mods:
		if mods_keys[i] == "internal":
			continue
		ModManager.load_mod(mods_keys[i])
	
	Registry.rebuild_database()
	print("Loaded!")

func find_item_in_itemlist(itemlist: ItemList, item: String) -> int:
	for i in itemlist.get_item_count():
		if itemlist.get_item_text(i) == item:
			return i
	return -1
