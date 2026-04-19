extends Node2D

func _on_pass_the_device_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main/pass_the_device_config.tscn")


func _on_peer_to_peer_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main/lobby.tscn")


func _on_back_to_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main/main_menu.tscn")
