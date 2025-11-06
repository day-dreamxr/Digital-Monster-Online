extends Node

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
signal saved

func _ready():
	save_timer = Timer.new()
	save_timer.one_shot = true
	save_timer.wait_time = 1.0
	save_timer.process_mode = Node.PROCESS_MODE_ALWAYS
	save_timer.timeout.connect(_on_save_timer_timeout)
	add_child(save_timer)
	var err = load_preferences()
	if err:
		pass

func save_when_ready() -> void:
	save_timer.start()

func _on_save_timer_timeout() -> void:
	save_preferences()

func load_preferences() -> Error:
	var file := FileAccess.open("user://save_data.json", FileAccess.READ)
	var err := FileAccess.get_open_error()
	if err != OK:
		if err == ERR_FILE_NOT_FOUND:
			body_color = Color(1, 1, 1, 1)
			cage_color = Color(1, 1, 1, 1)
			background_color = Color(0, 0, 0, 1)
			screen_background_index = 0
			save_preferences()
			return OK
		return err
	
	var json = JSON.parse_string(file.get_as_text())
	if json is Dictionary:
		body_color = Color.html(json.get("body_color", body_color))
		cage_color = Color.html(json.get("cage_color", cage_color))
		background_color = Color.html(json.get("background_color", background_color))
		screen_background_index = json.get("screen_background_index", screen_background_index)
	else:
		save_preferences()
	return OK

func save_preferences() -> Error:
	var file := FileAccess.open("user://save_data.json", FileAccess.WRITE)
	var err := FileAccess.get_open_error()
	if err:
		return err
	
	file.store_string(JSON.stringify({
		"body_color": body_color.to_html(),
		"cage_color": cage_color.to_html(),
		"background_color": background_color.to_html(),
		"screen_background_index": screen_background_index,
	}))
	saved.emit()
	return OK
