extends Node

signal body_color_changed(new_value: Color)
signal cage_color_changed(new_value: Color)
signal background_color_changed(new_value: Color)

func _ready() -> void:
	$Digivice.modulate = SaveData.body_color
	%BodyColorPicker.color = SaveData.body_color
	$Cage.modulate = SaveData.cage_color
	%CageColorPicker.color = SaveData.cage_color
	RenderingServer.set_default_clear_color(SaveData.background_color)
	%BackgroundColorPicker.color = SaveData.background_color

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
