extends Node2D

@onready var bot_count_label = get_node("Panel/VBox/HBox/BotCountLabel")
@onready var decrease_button = get_node("Panel/VBox/HBox/DecreaseButton")
@onready var increase_button = get_node("Panel/VBox/HBox/IncreaseButton")
@onready var start_button    = get_node("Panel/VBox/StartButton")
@onready var back_button     = get_node("Panel/VBox/BackButton")

var bot_count: int = 1
const MIN_BOTS = 1
const MAX_BOTS = 3

func _ready() -> void:
	decrease_button.pressed.connect(_on_decrease_pressed)
	increase_button.pressed.connect(_on_increase_pressed)
	start_button.pressed.connect(_on_start_pressed)
	back_button.pressed.connect(_on_back_pressed)
	_update_display()

func _on_decrease_pressed() -> void:
	if bot_count > MIN_BOTS:
		bot_count -= 1
		_update_display()

func _on_increase_pressed() -> void:
	if bot_count < MAX_BOTS:
		bot_count += 1
		_update_display()

func _update_display() -> void:
	bot_count_label.text = str(bot_count)
	decrease_button.disabled = bot_count <= MIN_BOTS
	increase_button.disabled = bot_count >= MAX_BOTS

func _on_start_pressed() -> void:
	GameConfig.bot_count = bot_count
	
	get_tree().change_scene_to_file("res://scenes/main/game.tscn")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main/main_menu.tscn")
