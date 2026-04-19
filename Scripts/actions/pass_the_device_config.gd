extends Node2D

@onready var player_slider = $Button_manager/HSlider
@onready var player_label = $PlayerLabel

func _on_h_slider_value_changed(value: float) -> void:
	update_label(value)
	
func _ready() -> void:
	update_label(player_slider.value)
	
func update_label(value):
	player_label.text = "Players: %d" % int(value)

func _on_back_to_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main/main_menu.tscn")


func _on_start_game_pressed() -> void:
	PassTheDeviceSettings.player_count = player_slider.value
	get_tree().change_scene_to_file("res://Scenes/main/pass_the_device.tscn")
