extends ColorRect

@onready var game_manager = get_node("../../GameManager")
@onready var hand_view = get_node("../../PlayerHand")

func _on_button_pressed() -> void:
	game_manager.next_turn()
	hand_view.player_data = game_manager.players[game_manager.current_player_index]
	hand_view.refresh()
	self.visible = false
