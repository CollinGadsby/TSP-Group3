extends Node2D
	
func _on_singleplayer_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main/game.tscn")

	
func _on_multiplayer_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main/game.tscn")


func _on_tutorial_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main/tutorial.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
