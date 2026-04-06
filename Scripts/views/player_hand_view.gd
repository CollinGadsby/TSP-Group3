extends Node2D

var player_data: PlayerData
@onready var game_manager = get_node("../GameManager")
@onready var discard_stack = get_node("../DiscardStack")

@export var card_scene: PackedScene

func refresh() -> void:
	if player_data == null or card_scene == null:
		return
	player_data.hand.sort_custom(func(a, b): return a.rank < b.rank)
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
	
	# Dynamically calculate spacing so cards always fit on screen
	var available_width = screen_size.x - 80  # 40px margin each side
	var max_spacing = 80  # max padding when few cards
	var min_spacing = 10  # min padding before cards heavily overlap
	var spacing = clamp(
		(available_width - card_width) / max(total - 1, 1),
		min_spacing,
		card_width + max_spacing
	)
	
	var total_width = card_width + (total - 1) * spacing
	var start_x = (screen_size.x - total_width) / 2
	
	for i in range(total):
		var card_node = card_scene.instantiate()
		card_node.setup(player_data.hand[i])
		var x_pos = start_x + i * spacing
		var y_pos = screen_size.y - card_height - (card_height / 2)
		card_node.position = Vector2(x_pos, y_pos)
		add_child(card_node)

func bind():	
	if not player_data.hand_changed.is_connected(refresh):
		player_data.hand_changed.connect(refresh)
	if not game_manager.hand_changed.is_connected(refresh):
		game_manager.hand_changed.connect(refresh)
