extends Node2D

var player_data: PlayerData
@onready var game_manager = get_node("/root/GameScene/GameManager")
@onready var discard_stack = get_node("/root/GameScene/DiscardStack")

@export var card_scene: PackedScene

func refresh() -> void:
	if player_data == null or card_scene == null:
		return
		
	if game_manager.deck.discard_pile.is_empty():
		discard_stack.empty()

	for c in get_children():
		c.queue_free()

	var total = player_data.hand.size()
	if total == 0:
		return

	var screen_size = get_viewport_rect().size
	var card_width = 80
	var card_height = 112.5
	var padding = 80

	var total_width = total * card_width + (total - 1) * padding
	var start_x = ((screen_size.x - total_width) / 2) - 40

	for i in range(total):
		var card_node = card_scene.instantiate()
		card_node.setup(player_data.hand[i])

		# Position each card
		var x_pos = start_x + i * (card_width + padding)
		var y_pos = screen_size.y - card_height - (112.5 / 2)
		card_node.position = Vector2(x_pos, y_pos)

		add_child(card_node)

func bind():	
	player_data.hand_changed.connect(refresh)
	game_manager.hand_changed.connect(refresh)
