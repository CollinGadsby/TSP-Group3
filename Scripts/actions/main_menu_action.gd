extends Node2D


@onready var how_to_play = get_node("HowToPlay")  
@onready var how_to_play_button = get_node("Button_manager/HowToPlayButton")  

func _ready() -> void:
	how_to_play_button.pressed.connect(how_to_play.show_panel)
	
func _on_singleplayer_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main/game.tscn")

	
func _on_multiplayer_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main/game.tscn")


func _on_tutorial_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main/tutorial.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
