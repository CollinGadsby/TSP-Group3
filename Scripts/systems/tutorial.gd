extends Node2D

@onready var game_manager = $GameScene/GameManager
@onready var hand_view = $GameScene/PlayerHand
@onready var deck_stack = $GameScene/DeckStack
@onready var discard_stack = $GameScene/DiscardStack
@onready var debug_overlay = $GameScene/DebugOverlay
@onready var text_box = $TextBox
@onready var text_box_button = $TextBox/Button

### Tutorial API
# 	dialog: Text display 
# 	action: callable function, api below
#	button_action: If button calls the action
#	card_data: Data of the card clicked


### Action API
#	show_hand: Shows the hand and discard stack / updates them, only for start
#	wait_for_draw_stack: waits for the player to click on the draw stack
# 	wait_for_select_card: waits for the player to select the the correct card
#	wait_for_discard_selected: waits for the player to select the discard pile with a selected card
#	wait_for_draw_discard: waits for the player to draw a card from the discard pile
#	back_to_menu: returns the player back to the main menu
#
#	NOTE feel free to add more functions just remember to put them into the api

var tutorials = [
	{	## Id:0
		"steps": [
			{
				"dialog": "Welcome, click next to start the tutorial",
				"action": Callable(self, "show_hand"),
				"button_action": true
			},
			{
				"dialog": "Click on the draw pile",
				"action": Callable(self, "wait_for_draw_stack"),
				"button_action": false
			},
			{
				"dialog": "Click card the queen of hearts",
				"action": Callable(self, "wait_for_select_card"),
				"button_action": false,
				"card_data": CardData.new(CardData.Suit.HEARTS, 12)
			},
			{
				"dialog": "Click on the discard pile",
				"action": Callable(self, "wait_for_discard_selected"),
				"button_action": false
			},
			{
				"dialog": "Congrats! Click continue button to return to the main menu",
				"action": Callable(self, "back_to_menu"),
				"button_action": true
			}
		],

		"hand": [
			CardData.new(CardData.Suit.SPADES, 3),
			CardData.new(CardData.Suit.SPADES, 4),
			CardData.new(CardData.Suit.HEARTS, 12)
		],

		"discard": [
			CardData.new(CardData.Suit.CLUBS, 8)
		],

		"draw": [
			CardData.new(CardData.Suit.SPADES, 5)
		]
	},

	{
		# Id:1
		"steps": [
			{
				"dialog": "Welcome to Tutorial 2",
				"action": Callable(self, "show_hand"),
				"button_action": true
			}
		],

		"hand": [
			CardData.new(CardData.Suit.HEARTS, 2)
		],

		"discard": [],
		"draw": []
	}
]

var current_step: int = 0
var tutorial_index = 0

func _ready() -> void:
	debug_overlay.bind()
	game_manager.start_tutorial(tutorial_index)
	game_manager.tutorial_mode = true
	
	var player = game_manager.get_current_player()

	hand_view.player_data = player
	hand_view.bind()

	deck_stack.refresh()
	
	show_step()
	
func show_step():
	if current_step >= tutorials[tutorial_index]["steps"].size():
		return
	var step = tutorials[tutorial_index]["steps"][current_step]
	text_box.update_text(step["dialog"])
	text_box.setDialogVisible(true)
	if step["button_action"]:
		text_box.setButtonVisible(true)
		set_button()
	else:
		text_box.setButtonVisible(false)
		if step.has("action"):
			step["action"].call()
			
		
func next_step():
	current_step += 1
	show_step()

func set_button():
	text_box_button.pressed.connect(func():
		text_box.setButtonVisible(false)
		var step = tutorials[tutorial_index]["steps"][current_step]
		
		if step["button_action"]:
			if step.has("action"):
				step["action"].call()
	)

func show_hand():
	hand_view.refresh()
	discard_stack.update_visual()
	next_step()
	
func wait_for_draw_stack():
	if not game_manager.is_connected("draw_from_deck_sig", _on_wait_for_draw_stack):
		game_manager.connect("draw_from_deck_sig", _on_wait_for_draw_stack)
		game_manager.draw_stack_lock = false

func _on_wait_for_draw_stack():
	game_manager.disconnect("draw_from_deck_sig", _on_wait_for_draw_stack)
	game_manager.draw_stack_lock = true
	next_step()

func wait_for_select_card():
	for card in hand_view.get_children():
		var area2d = card.get_node("FrontCardBacking/Area2D")
		if not area2d.is_connected("select_card_sig", _on_wait_for_select_card):
			area2d.connect("select_card_sig", _on_wait_for_select_card)
			
	game_manager.select_lock = false

func _on_wait_for_select_card(card_data: CardData):
	var step = tutorials[tutorial_index]["steps"][current_step]
	if card_data.rank == step["card_data"].rank and card_data.suit == step["card_data"].suit:
		game_manager.select_lock = true
		for card in hand_view.get_children():
			var area2d = card.get_node("FrontCardBacking/Area2D")
			area2d.disconnect("select_card_sig", _on_wait_for_select_card)
		next_step()
	else:
		text_box.update_text("You selected the wrong card, try again")

func wait_for_discard_selected():
	var area2d = discard_stack.get_node("FrontCardBacking/Area2D")
	if not area2d.is_connected("discard_selected", _on_wait_for_discard_selected):
		area2d.connect("discard_selected", _on_wait_for_discard_selected)
		game_manager.discard_lock = false
	
func _on_wait_for_discard_selected():
	var area2d = discard_stack.get_node("FrontCardBacking/Area2D")
	area2d.disconnect("discard_selected", _on_wait_for_discard_selected)
	game_manager.discard_lock = true
	next_step()
	
func wait_for_draw_discard():
	var area2d = discard_stack.get_node("FrontCardBacking/Area2D")
	if not area2d.is_connected("draw_discard", _on_wait_for_draw_discard):
		area2d.connect("draw_discard", _on_wait_for_draw_discard)
		game_manager.draw_discard_lock = false

func _on_wait_for_draw_discard():
	var area2d = discard_stack.get_node("FrontCardBacking/Area2D")
	area2d.disconnect("draw_discard", _on_wait_for_draw_discard)
	game_manager.draw_discard_lock = true
	next_step()
	
func back_to_menu():
	if get_tree(): 
		get_tree().change_scene_to_file("res://scenes/main/main_menu.tscn")
