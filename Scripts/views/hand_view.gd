extends Node2D

@export var card_scene: PackedScene
var game_manager: GameManager

func show_hand(player: PlayerData):

	for child in get_children():
		child.queue_free()

	var spacing = 120

	for i in range(player.hand.size()):
		var card_data = player.hand[i]

		var card = card_scene.instantiate()
		add_child(card)

		card.setup(card_data)

		card.position = Vector2(i * spacing, 0)
