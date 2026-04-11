extends Node2D

@onready var game_manager = $GameScene/GameManager
@onready var hand_view = $GameScene/PlayerHand
@onready var deck_stack = $GameScene/DeckStack
@onready var discard_stack = $GameScene/DiscardStack
@onready var debug_overlay = $GameScene/DebugOverlay

func _ready() -> void:
	debug_overlay.bind()
	game_manager.start_pass_the_device()
	game_manager.pass_the_device_mode = true
	
	var player = game_manager.get_current_player()

	hand_view.player_data = player
	hand_view.bind()
	
	hand_view.refresh()
	deck_stack.refresh()
