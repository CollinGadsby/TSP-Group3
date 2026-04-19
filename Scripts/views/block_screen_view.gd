extends ColorRect

@onready var game_manager = get_node("../../GameManager")
@onready var hand_view = get_node("../../PlayerHand")

func _on_button_pressed() -> void:
	if game_manager.going_out_player_index != -1 and not game_manager.last_round_remaining.is_empty():
		game_manager._advance_to_next_last_round_player()
	hand_view.player_data = game_manager.players[game_manager.current_player_index]
	hand_view.refresh()
	game_manager.update_turn_label()
	self.visible = false
