extends Panel

@export var button : Button

func _on_settings_button_pressed() -> void:
	do_panel_toggle()

func _on_close_button_pressed() -> void:
	do_panel_toggle()

func do_panel_toggle():
	if visible:
		button.visible = true
		visible = false
	else:
		button.visible = false
		visible = true
