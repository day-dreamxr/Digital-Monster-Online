extends Node

func _ready() -> void:
	%BodyColorPicker.color = $Digivice.modulate
	%CageColorPicker.color = $Digivice.modulate
	%BackgroundColorPicker.color = RenderingServer.get_default_clear_color()

func _on_button_pressed() -> void:
	AudioPlayer.beep.play()

func _on_options_button_pressed() -> void:
	$Options.show()

func _on_body_color_changed(color: Color) -> void:
	$Digivice.modulate = color

func _on_cage_color_changed(color: Color) -> void:
	$Cage.modulate = color

func _on_background_color_changed(color: Color) -> void:
	RenderingServer.set_default_clear_color(color)

func _on_close_button_pressed() -> void:
	$Options.hide()
