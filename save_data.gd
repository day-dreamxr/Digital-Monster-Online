extends Node
# Based on 'preferences.gd' from https://github.com/boardshapes/boardwalk
# Thank you to https://github.com/jaredtalbot from Boardshapes for the original version of this file

#Digivice Customization
var body_color := Color():
	set(value):
		body_color = value
		body_color_changed.emit(body_color)

var cage_color := Color():
	set(value):
		cage_color = value
		cage_color_changed.emit(cage_color)

var background_color := Color():
	set(value):
		background_color = value
		background_color_changed.emit(background_color)

var screen_background_index := int():
	set(value):
		screen_background_index = value
		screen_background_index_changed.emit(value)

var save_timer: Timer

signal body_color_changed(new_value: Color)
signal cage_color_changed(new_value: Color)
signal background_color_changed(new_value: Color)
signal screen_background_index_changed(new_value: int)
signal digivice_saved

#Digimon Data
var id := int():
	set(value):
		id = value
		id_changed.emit(value)

var age := int():
	set(value):
		age = value
		age_changed.emit(value)

var weight := int():
	set(value):
		weight = value
		weight_changed.emit(value)

var hunger := int():
	set(value):
		hunger = value
		hunger_changed.emit(value)

var strength := int():
	set(value):
		strength = value
		strength_changed.emit(value)

var effort := int():
	set(value):
		effort = value
		effort_changed.emit(value)

var battles := int():
	set(value):
		battles = value
		battles_changed.emit(value)

var care_mistakes := int():
	set(value):
		care_mistakes = value
		care_mistakes_changed.emit(value)

var overfeeds := int():
	set(value):
		overfeeds = value
		overfeeds_changed.emit(value)

var time_until_evolution := float():
	set(value):
		time_until_evolution = value
		time_until_evolution_changed.emit(value)

signal id_changed(new_value: int)
signal age_changed(new_value: int)
signal weight_changed(new_value: int)
signal hunger_changed(new_value: int)
signal strength_changed(new_value: int)
signal effort_changed(new_value: int)
signal battles_changed(new_value: int)
signal care_mistakes_changed(new_value: int)
signal overfeeds_changed(new_value: int)
signal time_until_evolution_changed(new_value: float)
signal digimon_saved

func _ready():
	time_until_evolution = 60
	save_timer = Timer.new()
	save_timer.one_shot = true
	save_timer.wait_time = 1.0
	save_timer.process_mode = Node.PROCESS_MODE_ALWAYS
	save_timer.timeout.connect(_on_save_timer_timeout)
	add_child(save_timer)
	var err = load_save_data("digivice")
	if err:
		pass
	err = load_save_data("digimon")
	if err:
		pass

func save_when_ready() -> void:
	save_timer.start()

func _on_save_timer_timeout() -> void:
	save_preferences("digivice")
	save_preferences("digimon")

func load_save_data(type: String) -> Error:
	var file := FileAccess.open("user://"+type+".json", FileAccess.READ)
	var err := FileAccess.get_open_error()
	if err != OK:
		if err == ERR_FILE_NOT_FOUND:
			if type == "digivice":
				body_color = Color(1, 1, 1, 1)
				cage_color = Color(1, 1, 1, 1)
				background_color = Color(0, 0, 0, 1)
				screen_background_index = 0
				save_preferences("digivice")
				return OK
		return err
	
	var json = JSON.parse_string(file.get_as_text())
	if json is Dictionary:
		if type == "digivice":
			body_color = Color.html(json["body_color"]) if "body_color" in json else body_color
			cage_color = Color.html(json["cage_color"]) if "cage_color" in json else body_color
			background_color = Color.html(json["background_color"]) if "background_color" in json else body_color
			screen_background_index = json.get("screen_background_index", screen_background_index)
		else:
			id = json.get("id", id)
			age = json.get("age", age)
			weight = json.get("weight", weight)
			hunger = json.get("hunger", hunger)
			strength = json.get("strength", strength)
			effort = json.get("effort", effort)
			battles = json.get("battles", battles)
			care_mistakes = json.get("care_mistakes", care_mistakes)
			overfeeds = json.get("overfeeds", overfeeds)
			time_until_evolution = json.get("time_until_evolution", time_until_evolution)
	else:
		save_preferences(type)
	return OK

func save_preferences(type: String) -> Error:
	var file := FileAccess.open("user://"+type+".json", FileAccess.WRITE)
	var err := FileAccess.get_open_error()
	if err:
		return err
	if type == "digivice":
		file.store_string(JSON.stringify({
			"body_color": body_color.to_html(),
			"cage_color": cage_color.to_html(),
			"background_color": background_color.to_html(),
			"screen_background_index": screen_background_index,
		}))
		digivice_saved.emit()
	else:
		file.store_string(JSON.stringify({
			"id": id,
			"age": age,
			"weight": weight,
			"hunger": hunger,
			"strength": strength,
			"effort": effort,
			"battles": battles,
			"care_mistakes": care_mistakes,
			"overfeeds": overfeeds,
			"time_until_evolution": time_until_evolution,
		}))
		digivice_saved.emit()
	return OK

func export_save_data() -> void:
	var save_data = {
		"body_color": body_color.to_html(),
		"cage_color": cage_color.to_html(),
		"background_color": background_color.to_html(),
		"screen_background_index": screen_background_index,
	}
	var json = JSON.stringify(save_data)
	if OS.has_feature("web"):
		JavaScriptBridge.download_buffer(json.to_utf8_buffer(), "digivice.json", "application/json")
	else:
		var file := FileAccess.open("user://digivice.json", FileAccess.WRITE)
		file.store_string(json)
		file.close()
		OS.shell_show_in_file_manager(ProjectSettings.globalize_path("user://digivice.json"))
	
func import_save_data(content: PackedByteArray):
	var json = JSON.parse_string(content.get_string_from_utf8())
	if json is Dictionary:
		body_color = Color.html(json.get("body_color", body_color))
		cage_color = Color.html(json.get("cage_color", cage_color))
		background_color = Color.html(json.get("background_color", background_color))
		screen_background_index = json.get("screen_background_index", screen_background_index)
	save_preferences("digivice")
