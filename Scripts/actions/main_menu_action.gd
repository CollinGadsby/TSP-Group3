extends Node2D


@onready var how_to_play = get_node("HowToPlay")  
@onready var how_to_play_button = get_node("Button_manager/HowToPlayButton") 
@onready var mute_button = get_node("Button_manager/Mute") 

func _ready() -> void:
	update_mute_label()
	how_to_play_button.pressed.connect(how_to_play.show_panel)

func _on_mute_button_pressed() -> void:
	AudioManager.toggle_mute()
	update_mute_label()

func update_mute_label() -> void:
	mute_button.text = "Mute" if not AudioManager.muted else "Unmute"
	
func _on_singleplayer_pressed() -> void:
	AudioManager.play(AudioManager.SFX_CLICK)
	get_tree().change_scene_to_file("res://Scenes/main/solo_config.tscn")

	
func _on_multiplayer_pressed() -> void:
	AudioManager.play(AudioManager.SFX_CLICK)
	get_tree().change_scene_to_file("res://Scenes/main/multiplayer_mode_menu.tscn")


func _on_tutorial_pressed() -> void:
	AudioManager.play(AudioManager.SFX_CLICK)
	get_tree().change_scene_to_file("res://Scenes/main/tutorial.tscn")


func _on_quit_pressed() -> void:
	AudioManager.play(AudioManager.SFX_CLICK)
	get_tree().quit()
