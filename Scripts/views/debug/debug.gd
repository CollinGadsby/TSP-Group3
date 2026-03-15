extends Node2D

@onready var game_manager = get_node("../GameManager")

var enabled: bool = false

func _input(event):
	if event.is_action_pressed("debug_overlay"):
		toggle_overlay()

func toggle_overlay() -> void:
	enabled = !enabled
	for child in get_children():
		if child is RichTextLabel:
			child.visible = enabled

func update() -> void:
	$GameState.bbcode_text = "[color=%s]%s[/color]" % ["white", "State: " + GlobalEnums.GameState.keys()[game_manager.state]]

func bind() -> void:
	game_manager.debug_data_changed.connect(update)
