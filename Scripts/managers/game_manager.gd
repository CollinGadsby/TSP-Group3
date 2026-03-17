extends Node2D
class_name GameManager

@onready var discard_stack = get_node("../DiscardStack")
@onready var round_label = get_node("../UI/RoundLabel")
@onready var game_state_label = get_node("../DebugOverlay/GameState")
@onready var tutorial = get_node("../../../Tutorial")

signal hand_changed
signal debug_data_changed
signal draw_from_deck_sig

var players: Array[PlayerData] = []
var current_player_index: int = 0

var round_index: int = 0
var deck: Deck

var tutorial_mode: bool = false
var draw_stack_lock: bool = true
var draw_discard_lock: bool = true
var select_lock: bool = true
var discard_lock: bool = true

var state: GlobalEnums.GameState = GlobalEnums.GameState.WAITING

func start_game(player_names) -> void:
	players.clear()
	
	for i in range(player_names.size()):
		var p = PlayerData.new()
		p.id = i
		p.name = player_names[i]
		
		players.append(p)
	
	discard_stack.discard_stack_pos()
	start_round()

func start_tutorial(id: int) -> void:
	players.clear()
	
	var p = PlayerData.new()
	p.id = 0
	p.name = "TutorialPlayer"
		
	players.append(p)
	
	discard_stack.discard_stack_pos()
	
	for card_data in tutorial.tutorials[id]["hand"]:
		p.hand.append(card_data)
	
	deck = Deck.new(0)
	deck.discard_pile.clear()
	deck.draw_pile.clear()
	
	for card_data in tutorial.tutorials[id]["draw"]:
		deck.draw_pile.append(card_data)
	
	for card_data in tutorial.tutorials[id]["discard"]:
		print(card_data.rank)
		deck.discard_pile.append(card_data)
	
	discard_stack.setup(deck.discard_pile[deck.discard_pile.size() - 1])
	discard_stack.empty()
	state = GlobalEnums.GameState.DRAWING
	emit_signal("debug_data_changed")

func start_round():
	round_index += 1
	round_label.bbcode_text = "[color=%s]%s%d[/color]" % ["white", "Round: ", round_index]
	
	var number_of_decks = 1
	deck = Deck.new(number_of_decks)
	
	for p in players:
		p.hand.clear()
		
	deal_cards(round_index + 2)
	
	state = GlobalEnums.GameState.DRAWING
	emit_signal("debug_data_changed")
	
func deal_cards(number_of_cards: int):
	for i in range(number_of_cards):
		for p in players:
			p.draw(deck)
			
	deck.discard(deck.draw_card())	# Flip top card
	discard_stack.setup(deck.discard_pile[deck.discard_pile.size() - 1])
			
func get_current_player():
	return players[current_player_index]

func next_turn():
	current_player_index += 1
	
	if current_player_index >= players.size():
		current_player_index = 0

func draw_from_deck():
	var player = get_current_player()
	player.draw(deck)

	state = GlobalEnums.GameState.DISCARDING
	emit_signal("debug_data_changed")
	emit_signal("draw_from_deck_sig")
	
func draw_from_discard():
	var player = get_current_player()
	if deck.discard_pile.size() > 0:
		player.hand.append(deck.discard_pile.pop_back())
		if deck.discard_pile.size() == 0:
			discard_stack.empty()
		else:
			discard_stack.setup(deck.discard_pile[deck.discard_pile.size() - 1])
		emit_signal("hand_changed")
		
	state = GlobalEnums.GameState.DISCARDING
	emit_signal("debug_data_changed")
	
func discard_card(index):
	var player = get_current_player()
	player.discard(index, deck)
	discard_stack.setup(deck.discard_pile[deck.discard_pile.size() - 1])
	
	state = GlobalEnums.GameState.DRAWING
	emit_signal("debug_data_changed")
	next_turn()
