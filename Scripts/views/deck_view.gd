extends Node2D

@export var card_scene: PackedScene
var deck: Node = null

func refresh() -> void:

	var screen_size = get_viewport_rect().size

	var x = screen_size.x / 2 - 100
	var y = screen_size.y / 2 - 50

	var card_node = card_scene.instantiate()

	card_node.position = Vector2(x, y)

	add_child(card_node)
