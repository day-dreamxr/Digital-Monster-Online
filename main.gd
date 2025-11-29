extends Node

const screen_bg_paths = ["res://sprites/backgrounds/grasslands.png",
	"res://sprites/backgrounds/desert.png",
	"res://sprites/backgrounds/forest.png",
	"res://sprites/backgrounds/mountains.png",
	"res://sprites/backgrounds/beach.png",
	"res://sprites/backgrounds/office.png"]

signal body_color_changed(new_value: Color)
signal cage_color_changed(new_value: Color)
signal background_color_changed(new_value: Color)
signal screen_background_index_changed(new_value: int)

@onready var buttons: Array[TextureButton] = [%TopButtons/Health, %TopButtons/Feed, %TopButtons/Train, %TopButtons/Battle, %TopButtons/Flush]
@onready var focus_index = -1
@onready var focused = false

@onready var health_screens = [%HealthMenu/Name, %HealthMenu/Age, %HealthMenu/Stats]
@onready var health_index = 0

@onready var feed_focus = 0

@onready var digimon = $ScreenBackground/Digimon

func _ready() -> void:
	digimon.stats_changed.connect(_set_stats)
	digimon.load_digimon()
	SaveData.digivice_saved.connect(reload_colors)
	reload_colors()
	digimon.initialize_timers()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("force_digivolve"):
		digimon.get_child(0).start(0.1)

func _set_stats() -> void:
	#Ensure stats are accurate
	if digimon.hunger > 4:
		digimon.hunger = 4
	if digimon.strength > 4:
		digimon.strength = 4
	if digimon.weight > 99:
		digimon.weight = 99
	%NameLabel.text = digimon.digimon_name
	%AgeLabel.text = str(digimon.age) + " A"
	%WeightLabel.text = str(digimon.weight) + " G"

func reload_colors() -> void:
	$Digivice.modulate = SaveData.body_color
	%BodyColorPicker.color = SaveData.body_color
	$Cage.modulate = SaveData.cage_color
	%CageColorPicker.color = SaveData.cage_color
	RenderingServer.set_default_clear_color(SaveData.background_color)
	%BackgroundColorPicker.color = SaveData.background_color
	$ScreenBackground.texture = load(screen_bg_paths[SaveData.screen_background_index])

func _on_button_pressed() -> void:
	AudioPlayer.beep.play()

func _on_options_button_pressed() -> void:
	%Options.show()

func _on_body_color_changed(color: Color) -> void:
	$Digivice.modulate = color
	SaveData.body_color = color
	SaveData.save_when_ready()
	body_color_changed.emit(color)

func _on_cage_color_changed(color: Color) -> void:
	$Cage.modulate = color
	SaveData.cage_color = color
	SaveData.save_when_ready()
	cage_color_changed.emit(color)

func _on_background_color_changed(color: Color) -> void:
	RenderingServer.set_default_clear_color(color)
	SaveData.background_color = color
	SaveData.save_when_ready()
	background_color_changed.emit(color)

func _on_close_button_pressed() -> void:
	%Options.hide()

func _on_cycle_screen_background_pressed() -> void:
	SaveData.screen_background_index += 1
	if SaveData.screen_background_index >= len(screen_bg_paths):
		SaveData.screen_background_index = 0
	$ScreenBackground.texture = load(screen_bg_paths[SaveData.screen_background_index])
	SaveData.save_when_ready()
	screen_background_index_changed.emit(SaveData.screen_background_index)

func _on_export_button_pressed() -> void:
	SaveData.export_save_data()

func _on_import_button_pressed() -> void:
	if OS.has_feature("web"):
		$WebSaveDataPicker.show()
	else:
		$SaveDataPicker.show()

func _on_save_data_selected(path: String) -> Error:
	var file := FileAccess.get_file_as_bytes(path)
	var err := FileAccess.get_open_error()
	if err != OK:
		return err
	SaveData.import_save_data(file)
	return OK

func _on_web_save_data_picker_file_loaded(content: PackedByteArray, _filename: String) -> void:
	SaveData.import_save_data(content)

func _on_a_pressed() -> void:
	if %HealthMenu.visible:
		health_screens[health_index].hide()
		health_index += 1
		if health_index >= len(health_screens):
			health_index = 0
			health_screens[health_index].show()
			%HealthMenu.hide()
			%TopButtons.show()
			digimon.show()
		else:
			health_screens[health_index].show()
	elif %FeedMenu.visible:
		if feed_focus == 0:
			feed_focus = 1
			%PillButton.grab_focus()
		else:
			feed_focus = 0
			%FoodButton.grab_focus()
	else:
		if digimon.stage != "Egg":
			focus_index += 1
			if focus_index >= len(buttons):
				focused = false
				focus_index = -1
			else:
				focused = true
				buttons[focus_index].grab_focus()

func _on_health_pressed() -> void:
	digimon.hide()
	%TopButtons.hide()
	%HealthMenu.show()

func _on_feed_pressed() -> void:
	digimon.hide()
	%TopButtons.hide()
	%FeedMenu.show()
	%FoodButton.grab_focus()

func _on_b_pressed() -> void:
	if %TopButtons.visible:
		if focused:
			buttons[focus_index].pressed.emit()
			focused = false
			focus_index = -1
		else:
			pass
			#show the clock
	elif %FeedMenu.visible:
		if feed_focus == 0:
			%FoodButton.pressed.emit()
		else:
			%PillButton.pressed.emit()

func _on_c_pressed() -> void:
	if %TopButtons.visible:
		focused = false
		focus_index = -1
	elif %HealthMenu.visible:
		health_index = 0
		health_screens[health_index].show()
		%HealthMenu.hide()
		%TopButtons.show()
		digimon.show()
	elif %FeedMenu.visible:
		%TopButtons.show()
		%FeedMenu.hide()
		digimon.show()

func _on_food_button_pressed() -> void:
	if digimon.hunger < 4:
		digimon.hunger += 1
		digimon.weight += 1
	else:
		digimon.overfeeds += 1
	digimon.get_child(4).start(3600)
	digimon.get_child(1).stop()
	_set_stats()
	digimon.save_digimon()

func _on_pill_button_pressed() -> void:
	if digimon.strength < 4:
		digimon.strength += 1
	digimon.get_child(5).start(3600)
	digimon.weight += 2
	digimon.get_child(2).stop()
	_set_stats()
	digimon.save_digimon()

func _on_train_pressed() -> void:
	if digimon.strength < 4:
		digimon.strength += 1
	digimon.effort += 1
	digimon.get_child(5).start(3600)
	digimon.get_child(2).stop()
	_set_stats()
	digimon.save_digimon()

func _on_battle_pressed() -> void:
	digimon.battles += 1
	digimon.save_digimon()

func _on_save_timer_timeout() -> void:
	digimon.save_digimon()
