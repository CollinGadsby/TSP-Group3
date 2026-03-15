@tool
extends EditorScript

func _ready() -> void:
	if Engine.is_editor_hint():
		var screen_size = DisplayServer.screen_get_size()
		var window = get_editor_interface().get_window()
		window.mode = Window.MODE_WINDOWED
		window.position = Vector2i(-8,0)
		window.size = Vector2i(screen_size.x - 66, screen_size.y - 1)
